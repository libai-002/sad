import router from '@ohos.router'
import { SearchBar } from '../components/SearchBar'
import { SquadResponse } from '../service/AppStore01'
import { SquadService } from '../service/SquadService'

/**
 * 搜索页面组件
 * 用于展示搜索结果和处理搜索逻辑
 */
@Entry
@Component
struct SearchPage {
  // 状态变量：存储搜索关键词
  @State private searchKeyword: string = ''
  // 状态变量：存储搜索结果
  @State private searchResults: Array<SquadResponse> = []
  // 状态变量：是否正在加载
  @State private isLoading: boolean = false
  // 状态变量：提示信息
  @State private errorMessage: string = ''
  
  // 组件生命周期：组件创建时获取路由参数
  aboutToAppear() {
    // 获取从上一个页面传递过来的搜索关键词
    const params = router.getParams() as Record<string, string>
    if (params && params.keyword) {
      this.searchKeyword = params.keyword
      // 自动执行搜索
      this.onSearch(params.keyword)
    }
  }
  
  /**
   * 执行搜索
   */
  private async onSearch(keyword: string) {
    if (!keyword.trim()) {
      return
    }
    
    this.isLoading = true
    
    try {
      // 调用后端API根据标签搜索小队
      const results = await SquadService.searchByTagLite(keyword)
      this.searchResults = results
    } catch (error) {
      console.error('搜索失败:', error)
      this.searchResults = []
    } finally {
      this.isLoading = false
    }
  }
  
  /**
   * 返回上一页
   */
  private goBack() {
    router.back()
  }

  /**
   * 加入小队
   * @param squadId 小队ID
   */
  private async joinSquad(squadId: number) {
    try {
      // 先获取完整的小队信息，包含 inviteCode 字段
      const squad = await SquadService.getSquadById(squadId)
      
      // 检查小队是否需要邀请码
      if (squad.inviteCode) {
        // 如果需要邀请码，显示提示信息
        this.errorMessage = '该小队需要邀请码才能加入，请输入邀请码'
      } else {
        // 不需要邀请码，直接加入小队
        await SquadService.joinSquad(squadId?.toString() || '')
        // 显示成功提示
        this.errorMessage = '加入小队成功'
      }
      // 3秒后清除提示
      setTimeout(() => {
        this.errorMessage = ''
      }, 3000)
    } catch (error) {
      // 显示失败提示
      this.errorMessage = error instanceof Error ? error.message : '加入小队失败'
      // 3秒后清除提示
      setTimeout(() => {
        this.errorMessage = ''
      }, 3000)
    }
  }
  
  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        Button('返回')
          .width('15%')
          .height('5%')
          .backgroundColor('#f5f5f5')
          .fontColor('#333333')
          .fontSize(16)
          .borderRadius(8)
          .onClick(() => this.goBack())
        
        Text('搜索')
          .fontSize(18)
          .fontColor('#333333')
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          
        Blank()
          .width('15%')
      }
      .width('100%')
      .padding({ top: '5%', bottom: '5%', left: '5%', right: '5%' })
      
      // 2. 搜索栏（使用复用的SearchBar组件）
      SearchBar({
        placeholder: '请输入队伍名称或关键词',
        onSearch: async (keyword: string) => await this.onSearch(keyword)
      })
      
      // 4. 提示信息
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4d4f')
          .margin({ top: 10 })
      }

      // 3. 搜索结果区域
      if (this.isLoading) {
        // 加载中状态
        Row() {
          Text('搜索中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('50%')
        .justifyContent(FlexAlign.Center)
      } else if (this.searchResults.length > 0) {
        // 搜索结果：使用Grid布局实现两行多列
        Grid() {
          ForEach(this.searchResults, (squad: SquadResponse) => {
            GridItem() {
              Column() {
                Text(squad.name || '未知队伍')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 8 })
                  .textAlign(TextAlign.Center)
                
                Text(squad.description || '无描述')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })
                  .textAlign(TextAlign.Center)
                  .maxLines(2)
                
                Text(`${squad.currentMembers}/${squad.maxMembers}人`)
                  .fontSize(14)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center)
                  .margin({ bottom: 12 })

                Button('加入小队')
                  .width('100%')
                  .height(40)
                  .backgroundColor('#1890ff')
                  .fontColor('#ffffff')
                  .fontSize(16)
                  .borderRadius(8)
                  .onClick(() => this.joinSquad(squad.id || 0))
              }
              .width('100%')
              .padding({ top: 16, right: 16, bottom: 16, left: 16 })
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .margin({ top: 8, right: 8, bottom: 8, left: 8 })
            }
          })
        }
        .columnsTemplate('1fr 1fr') // 两列布局
        .columnsGap(8)
        .rowsGap(8)
        .padding({ top: 8, right: 16, bottom: 16, left: 16 })
        .flexGrow(1)
        .width('100%')
      } else if (this.searchKeyword) {
        // 无搜索结果
        Row() {
          Text('未找到相关队伍')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('50%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 提示输入搜索关键词
        Row() {
          Text('请输入搜索关键词')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('50%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }
}
