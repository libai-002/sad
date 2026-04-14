import { NetworkService } from '../service/NetworkService'
import { AuthService, UserInfo } from '../service/AuthService'
import { LoginRequest } from '../model/LoginRequest'
import { LoginResponse } from '../model/LoginResponse'
import { ApiResponse } from '../model/ApiResponse'
import router from '@ohos.router'

/**
 * 鸿蒙SDK 5.0（HarmonyOS NEXT）登录页面
 * 功能包含：账号输入、密码输入（显隐切换）、登录表单校验、表单重置、登录/重置事件响应
 */
@Entry
@Component
struct LoginPage {
  // 状态变量：存储账号输入值（@State驱动UI更新）
  @State private account: string = ''
  // 状态变量：存储密码输入值
  @State private password: string = ''
  // 状态变量：控制密码是否隐藏（true：隐藏，false：显示）
  @State private isPwdHidden: boolean = true
  // 状态变量：存储表单校验错误提示信息
  @State private errorTip: string = ''
  // 状态变量：控制登录按钮是否可点击（防止重复点击）
  @State private isLoginDisabled: boolean = false

  /**
   * 登录按钮点击事件处理函数
   */
  private async onLoginClick(): Promise<void> {
    // 1. 清空之前的错误提示
    this.errorTip = ''

    // 2. 表单校验（非空校验+简单格式校验）
    if (!this.account.trim()) {
      this.errorTip = '请输入账号/手机号'
      return
    }
    if (!this.password.trim()) {
      this.errorTip = '请输入登录密码'
      return
    }
    // 手机号简单格式校验（可选扩展）
    const phoneReg = /^1[3-9]\d{9}$/
    if (this.account.length === 11 && !phoneReg.test(this.account.trim())) {
      this.errorTip = '请输入正确格式的手机号'
      return
    }
    // 密码长度校验（可选扩展）
    if (this.password.length < 6) {
      this.errorTip = '密码长度不能少于6位'
      return
    }

    try {
      // 3. 校验通过，执行登录逻辑
      this.isLoginDisabled = true
      this.errorTip = '登录请求已发送，正在验证...'
      
      // 4. 创建登录请求对象
      const loginRequest: LoginRequest = {
        username: this.account.trim(),
        password: this.password.trim()
      }
      
      // 5. 发送登录请求到Spring Boot后端
      const response = await NetworkService.post<ApiResponse<LoginResponse>>('/api/auth/login', loginRequest)
      
      // Debug: Log the full response
      console.log('Full login response:', JSON.stringify(response))
      
      // 6. 处理响应
      if (response.error) {
        // Handle different types of error responses
        if (typeof response.error === 'string') {
          this.errorTip = response.error
        } else if (typeof response.error === 'object' && response.error !== null) {
          // Handle validation errors or other error objects
          const errorObj = response.error as Record<string, string>
          // Join all error messages into a single string
          this.errorTip = Object.values(errorObj).join('；')
        } else {
          this.errorTip = '登录失败，请重试'
        }
      } else if (response.message) {
        this.errorTip = response.message
        // 登录成功，存储用户信息和令牌
        console.log('登录成功，用户信息：', JSON.stringify(response))
        
        // 存储令牌（从登录响应直接获取）
        AuthService.saveToken('dummy-token') // 后端没有返回token，使用占位符
        
        // 存储用户信息，使用实际的响应结构
        const userInfo: UserInfo = {
          id: response.userId,
          username: response.username,
          nickname: response.username, // 使用用户名作为昵称
          avatar: ''
        };
        AuthService.saveUserInfo(userInfo);
        // 输出账号的用户名
        console.log('登录成功，账号用户名：', userInfo.username);
        
        // 跳转到MainPage页面
        router.pushUrl({
          url: 'pages/MainPage'
        }).catch((error: Error) => {
          console.error('跳转页面失败：', error)
          this.errorTip = '登录成功，但跳转页面失败'
        })
      } else {
        this.errorTip = '登录失败，请重试'
      }
    } catch (error) {
      // 7. 处理网络错误
      let errMsg: string
      if (error instanceof Error) {
        errMsg = error.message
      } else if (typeof error === 'string') {
        errMsg = error
      } else if (typeof error === 'object' && error !== null) {
        // Handle error objects using Object.hasOwn instead of 'in' operator
        if (error.hasOwnProperty('message') && typeof (error as Record<string, string>).message === 'string') {
          errMsg = (error as Record<string, string>).message
        } else {
          errMsg = JSON.stringify(error)
        }
      } else {
        errMsg = '网络异常，请检查网络连接'
      }
      this.errorTip = errMsg
      console.error('登录请求失败：', error)
    } finally {
      // 8. 恢复登录按钮状态
      this.isLoginDisabled = false
    }
  }

  /**
   * 重置按钮点击事件处理函数（清空表单）
   */
  private onResetClick(): void {
    this.account = ''
    this.password = ''
    this.errorTip = ''
    this.isPwdHidden = true
  }

  /**
   * 密码显隐切换处理函数
   */
  private togglePwdVisible(): void {
    this.isPwdHidden = !this.isPwdHidden
  }

  build() {
    // 页面根布局：垂直排列（Column），居中对齐，占满整个屏幕
    Column() {
      // 1. 页面标题
      Text('用户登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 120, bottom: 80 })
        .fontColor('#1890ff')

      // 2. 账号输入框
      Row() {
        Text('账  号：')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
          .textAlign(TextAlign.Center)

        TextInput({
          placeholder: '请输入手机号/账号',
          text: this.account
        })
          .onChange((value: string) => {
            this.account = value
            // 输入时清空错误提示（提升用户体验）
            if (this.errorTip) this.errorTip = ''
          })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .border({
             width: 1,
            color: '#e5e5e5'
          })
          .flexGrow(1)
          .padding({ bottom: 8 })
      }
      .width('80%')
      .margin({ bottom: 30 })

      // 3. 密码输入框（带显隐切换）
      Row() {
        Text('密  码：')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
          .textAlign(TextAlign.Center)

        TextInput({
          placeholder: '请输入登录密码',
          text: this.password,
          // 控制密码显隐：Password为密码类型，Normal为普通文本类型

        }).type(  this.isPwdHidden ? InputType.Password : InputType.Normal)
          .onChange((value: string) => {
            this.password = value
            // 输入时清空错误提示（提升用户体验）
            if (this.errorTip) this.errorTip = ''
          })
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .border({
            width: 1,
            color: '#e5e5e5'
          })
          .flexGrow(1)
          .padding({ bottom: 8 })

        // 密码显隐切换按钮
        Text(this.isPwdHidden ? '显示' : '隐藏')
          .fontSize(14)
          .fontColor('#1890ff')
          .width(40)
          .onClick(() => this.togglePwdVisible())
      }
      .width('80%')
      .margin({ bottom: 40 })

      // 4. 错误提示/状态提示
      Text(this.errorTip)
        .fontSize(14)
        .fontColor('#ff4d4f')
        .margin({ bottom: 30 })
        .textAlign(TextAlign.Center)

      // 5. 功能按钮组（登录+重置）
      Row() {
        // 登录按钮
        Button('登  录')
          .width(120)
          .height(45)
          .backgroundColor(this.isLoginDisabled ? '#a0cfff' : '#1890ff')
          .fontColor('#ffffff')
          .fontSize(16)
          .borderRadius(8)
          .margin({ right: 20 })
          .enabled(!this.isLoginDisabled)
          .onClick(() => this.onLoginClick())

        // 重置按钮
        Button('重  置')
          .width(120)
          .height(45)
          .backgroundColor('#f5f5f5')
          .fontColor('#333333')
          .fontSize(16)
          .borderRadius(8)
          .onClick(() => this.onResetClick())
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}