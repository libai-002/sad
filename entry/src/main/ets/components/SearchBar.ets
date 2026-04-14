import router from '@ohos.router'

/**
 * 搜索栏组件
 * 可复用的搜索输入组件，支持自定义占位符和搜索回调
 */
@Component
export struct SearchBar {
  // 状态变量：存储搜索关键词
  @State private searchKeyword: string = ''
  
  // 组件参数
  private placeholder: string = '请输入搜索内容'
  private onSearch?: (keyword: string) => void | Promise<void>
  
  /**
   * 搜索按钮点击事件处理函数
   */
  private async onSearchClick(): Promise<void> {
    const trimmedKeyword = this.searchKeyword.trim()
    
    if (!trimmedKeyword) {
      return
    }
    
    // 如果提供了搜索回调，则调用回调
    if (this.onSearch) {
      await this.onSearch(trimmedKeyword)
    } else {
      // 默认行为：跳转到搜索页面
      router.pushUrl({
        url: 'pages/SearchPage',
        params: { keyword: trimmedKeyword }
      })
    }
  }
  
  build() {
    Row() {
      TextInput({
        placeholder: this.placeholder,
        text: this.searchKeyword
      })
        .onChange((value: string) => {
          this.searchKeyword = value
        })
        .fontSize(16)
        .fontColor('#333333')
        .placeholderColor('#999999')
        .borderRadius(8)
        .flexGrow(1)
        .padding({ left: '2%', right: '12%', top: '1%', bottom: '1%' })
        .margin({ right: '2%' })

      Button('搜索')
        .width('20%')
        .height('5%')
        .backgroundColor('#1890ff')
        .fontColor('#ffffff')
        .fontSize(16)
        .borderRadius(8)
        .onClick(() => this.onSearchClick())
    }
    .width('90%')
    .margin({ top: '5%', bottom: '7%' })
  }
}
