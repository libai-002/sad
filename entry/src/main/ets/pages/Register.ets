/**
 * 鸿蒙SDK 5.0（HarmonyOS NEXT）注册页面
 * 功能包含：账号输入、密码输入、确认密码、注册表单校验、表单重置、注册/重置事件响应
 */
import router from '@ohos.router';
@Entry
@Component
struct RegisterPage {
  // 状态变量：存储账号输入值（@State驱动UI更新）
  @State private account: string = ''
  // 状态变量：存储密码输入值
  @State private password: string = ''
  // 状态变量：存储确认密码输入值
  @State private confirmPassword: string = ''
  // 状态变量：控制密码是否隐藏（true：隐藏，false：显示）
  @State private isPwdHidden: boolean = true
  // 状态变量：控制确认密码是否隐藏（true：隐藏，false：显示）
  @State private isConfirmPwdHidden: boolean = true
  // 状态变量：存储表单校验错误提示信息
  @State private errorTip: string = ''

  /**
   * 注册按钮点击事件处理函数
   */
  private onRegisterClick(): void {
    // 1. 清空之前的错误提示
    this.errorTip = ''

    // 2. 表单校验（非空校验+格式校验+密码一致性校验）
    if (!this.account.trim()) {
      this.errorTip = '请输入账号/手机号'
      return
    }
    if (!this.password.trim()) {
      this.errorTip = '请输入登录密码'
      return
    }
    if (!this.confirmPassword.trim()) {
      this.errorTip = '请确认登录密码'
      return
    }
    
    // 手机号简单格式校验
    const phoneReg = /^1[3-9]\d{9}$/
    if (this.account.length === 11 && !phoneReg.test(this.account.trim())) {
      this.errorTip = '请输入正确格式的手机号'
      return
    }
    
    // 密码长度校验
    if (this.password.length < 6) {
      this.errorTip = '密码长度不能少于6位'
      return
    }
    
    // 密码一致性校验
    if (this.password !== this.confirmPassword) {
      this.errorTip = '两次输入的密码不一致'
      return
    }

    // 3. 校验通过，执行注册逻辑（此处为模拟，实际项目替换为真实接口请求）
    console.log(`注册请求：账号=${this.account.trim()}，密码=${this.password.trim()}`)
    // 模拟注册成功提示（实际项目可跳转登录页、存储登录态等）
    this.errorTip = '注册请求已发送，正在处理...'

    // 真实项目中可通过http请求库发送请求
    // example:
    // HttpRequest.post('/api/register', { account: this.account.trim(), password: this.password.trim() })
    //   .then(res => {
    //     if (res.code === 200) {
    //       // 注册成功，跳转登录页
    //       router.pushUrl({ url: 'pages/LoginPage' })
    //     } else {
    //       this.errorTip = res.msg || '注册失败，请重试'
    //     }
    //   })
    //   .catch(err => {
    //     this.errorTip = '网络异常，请检查网络连接'
    //     console.error('注册请求失败：', err)
    //   })
  }

  /**
   * 重置按钮点击事件处理函数（清空表单）
   */
  private onResetClick(): void {
    this.account = ''
    this.password = ''
    this.confirmPassword = ''
    this.errorTip = ''
    this.isPwdHidden = true
    this.isConfirmPwdHidden = true
  }

  /**
   * 密码显隐切换处理函数
   */
  private togglePwdVisible(): void {
    this.isPwdHidden = !this.isPwdHidden
  }

  /**
   * 确认密码显隐切换处理函数
   */
  private toggleConfirmPwdVisible(): void {
    this.isConfirmPwdHidden = !this.isConfirmPwdHidden
  }

  build() {
    // 页面根布局：垂直排列（Column），居中对齐，占满整个屏幕
    Column() {
      // 1. 页面标题
      Text('用户注册')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 60 })
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
          text: this.password
        }).type(this.isPwdHidden ? InputType.Password : InputType.Normal)
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
      .margin({ bottom: 30 })

      // 4. 确认密码输入框（带显隐切换）
      Row() {
        Text('确认密码：')
          .fontSize(16)
          .fontColor('#333333')
          .width(100)
          .textAlign(TextAlign.Center)

        TextInput({
          placeholder: '请再次输入登录密码',
          text: this.confirmPassword
        }).type(this.isConfirmPwdHidden ? InputType.Password : InputType.Normal)
          .onChange((value: string) => {
            this.confirmPassword = value
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

        // 确认密码显隐切换按钮
        Text(this.isConfirmPwdHidden ? '显示' : '隐藏')
          .fontSize(14)
          .fontColor('#1890ff')
          .width(40)
          .onClick(() => this.toggleConfirmPwdVisible())
      }
      .width('80%')
      .margin({ bottom: 40 })

      // 5. 错误提示/状态提示
      Text(this.errorTip)
        .fontSize(14)
        .fontColor('#ff4d4f')
        .margin({ bottom: 30 })
        .textAlign(TextAlign.Center)

      // 6. 功能按钮组（注册+重置）
      Row() {
        // 注册按钮
        Button('注  册')
          .width(120)
          .height(45)
          .backgroundColor('#1890ff')
          .fontColor('#ffffff')
          .fontSize(16)
          .borderRadius(8)
          .margin({ right: 20 })
          .onClick(() => this.onRegisterClick())

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
      
      // 7. 登录链接
      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#333333')
        Text('立即登录')
          .fontSize(14)
          .fontColor('#1890ff')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Index'
            })
          })
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}
