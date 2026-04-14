import router from '@ohos.router'
import { AuthService } from '../service/AuthService'
import { UserService, UserProfile, FriendInfo, AccountSecurity } from '../service/UserService'
import { SquadService } from '../service/SquadService'
import { ChatService, ChatRoomResponse } from '../service/ChatService'
import { AppStore01, SquadResponse } from '../service/AppStore01'
import { SearchBar } from '../components/SearchBar'

/**
 * 鸿蒙SDK 5.0（HarmonyOS NEXT）主页面
 * 功能包含：底部导航栏、页面切换、固定底部导航
 */
@Entry
@Component
struct MainPage {
  // 状态变量：当前选中的页面索引
  @State private currentIndex: number = 0

  build() {
    // 页面根布局：垂直排列（Column），占满整个屏幕
    Column() {
      // 内容区域：根据当前索引显示不同页面
      Stack({ alignContent: Alignment.TopStart }) {
        // 组队大厅页面
        if (this.currentIndex === 0) {
          TeamLobbyContent()
        }
        // 我的小队页面
        else if (this.currentIndex === 1) {
          MyTeamContent()
        }
        // 小队天地页面
        else if (this.currentIndex === 2) {
          SquadWorldContent()
        }
        // 个人中心页面
        else if (this.currentIndex === 3) {
          MyPageContent()
        }
      }
      .flexGrow(1)
      .width('100%')
      .height("90%")
      // 底部导航栏：固定在底部
      Row() {
        // 组队大厅
        Column() {
          Text('组队大厅')
            .fontSize(16)
            .fontColor(this.currentIndex === 0 ? '#1890ff' : '#333333')
            .textAlign(TextAlign.Center)
        }
        .flexGrow(1)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          this.currentIndex = 0
        })

        // 我的小队
        Column() {
          Text('我的小队')
            .fontSize(16)
            .fontColor(this.currentIndex === 1 ? '#1890ff' : '#333333')
            .textAlign(TextAlign.Center)
        }
        .flexGrow(1)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          this.currentIndex = 1
        })

        // 小队天地
        Column() {
          Text('小队天地')
            .fontSize(16)
            .fontColor(this.currentIndex === 2 ? '#1890ff' : '#333333')
            .textAlign(TextAlign.Center)
        }
        .flexGrow(1)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          this.currentIndex = 2
        })

        // 我的
        Column() {
          Text('我的')
            .fontSize(16)
            .fontColor(this.currentIndex === 3 ? '#1890ff' : '#333333')
            .textAlign(TextAlign.Center)
        }
        .flexGrow(1)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          this.currentIndex = 3
        })
      }
       .margin({top:"10%"})
             .width('100%')
      .height("10%")
      .backgroundColor('#f5f5f5')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }
}

/**
 * 组队大厅页面内容组件
 */
@Component
struct TeamLobbyContent {
  // 状态变量：存储搜索结果
  @State private searchResult: string = ''
  // 响应式绑定小队数据
  @StorageLink('squads') private squads: Array<SquadResponse> = []
  // 响应式绑定加载状态
  @StorageLink('loading') private loading: boolean = false
  // 响应式绑定无更多数据状态
  @StorageLink('noMoreData') private noMoreData: boolean = false

  // 组件生命周期：组件创建时初始化数据
  aboutToAppear() {
    // 检查是否已有小队数据，如果没有则加载
    const existingSquads = AppStore01.getSquads();
    if (existingSquads.length === 0) {
      // 只有在没有数据时才加载新数据
      this.loadMoreSquads();
    } else {
      console.log('使用已存储的小队数据，数量:', existingSquads.length);
    }
  }

  /**
   * 搜索按钮点击事件处理函数
   */
  private onSearchClick(keyword: string): void {
    // 跳转到搜索页面并传递搜索关键词
    router.pushUrl({
      url: 'pages/SearchPage',
      params: { keyword: keyword }
    })
  }

  /**
   * 加载更多小队数据的处理函数
   */
  private async loadMoreSquads(): Promise<void> {
    if (this.loading || this.noMoreData) return // 防止重复加载或已无更多数据
    
    AppStore01.setLoading(true)
    console.log('开始加载更多小队数据...')
    
    try {
      // 调用后端接口获取随机不重复的小队
      const allSquads = await SquadService.getRandomUniqueSquads(4)
      
      // 检查是否有新数据
      if (allSquads.length > 0) {
        console.log('加载小队数据完成，总小队数量:', allSquads.length)
      } else {
        // 无更多数据
        AppStore01.setNoMoreData(true)
        console.log('无更多小队数据')
      }
    } catch (error) {
      console.error('加载小队数据失败:', error)
      // 显示错误提示
      this.searchResult = `加载失败：${error instanceof Error ? error.message : '未知错误'}`
      setTimeout(() => {
        this.searchResult = ''
      }, 3000)
    } finally {
      AppStore01.setLoading(false)
      console.log('加载状态已重置为 false')
    }
  }

  /**
   * 加入小队处理函数
   * @param squadId 小队ID
   */
  private async joinSquad(squadId: number): Promise<void> {
    if (!squadId) {
      console.error('加入标识符不能为空')
      return
    }
    
    try {
      // 先获取完整的小队信息，包含 inviteCode 字段
      const squad = await SquadService.getSquadById(squadId)
      
      // 检查小队是否需要邀请码
      if (squad.inviteCode) {
        // 如果需要邀请码，显示提示信息
        this.searchResult = '该小队需要邀请码才能加入，请输入邀请码'
      } else {
        // 不需要邀请码，直接加入小队
        const result = await SquadService.joinSquad(squadId?.toString() || '')
        console.log('加入小队成功:', result)
        // 显示成功提示
        this.searchResult = `加入成功：${result.name || '未知小队'}`
      }
      
      // 3秒后清除提示
      setTimeout(() => {
        this.searchResult = ''
      }, 3000)
    } catch (error) {
      console.error('加入小队失败:', error)
      // 显示失败提示
      this.searchResult = `加入失败：${error instanceof Error ? error.message : '未知错误'}`
      
      // 3秒后清除提示
      setTimeout(() => {
        this.searchResult = ''
      }, 3000)
    }
  }

  build() {
    Column() {
      // 1. 搜索栏（页面最上面）
      SearchBar({
        placeholder: '请输入队伍名称或关键词',
        onSearch: (keyword: string): void => this.onSearchClick(keyword)
      })

      // 2. 搜索结果展示
      Text(this.searchResult)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ bottom: '5%' })
        .textAlign(TextAlign.Center)

      // 3. List组件实现上拉刷新功能
      List({ space: 10 }) {
        ForEach(this.squads, (squad: SquadResponse) => {
          ListItem() {
            Column() {
              // 小队名称
              Row() {
                Text('小队名称:')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(squad.name || '未知')
                  .fontSize(16)
                  .fontColor('#333333')
                  .flexGrow(1)
              }
              .width('100%')
              .margin({ bottom: 10 })

              // 小队描述
              Row() {
                Text('描述:')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(squad.description || '无')
                  .fontSize(16)
                  .fontColor('#333333')
                  .flexGrow(1)
              }
              .width('100%')
              .margin({ bottom: 10 })

              // 小队标签
              Row() {
                Text('标签:')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(squad.tags || '无')
                  .fontSize(16)
                  .fontColor('#333333')
                  .flexGrow(1)
              }
              .width('100%')
              .margin({ bottom: 10 })

              // 成员信息
              Row() {
                Text('成员:')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(`${squad.currentMembers || 0}/${squad.maxMembers || 0}`)
                  .fontSize(16)
                  .fontColor('#333333')
                  .flexGrow(1)
              }
              .width('100%')
              .margin({ bottom: 10 })

              // 队长信息
              Row() {
                Text('队长:')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ right: 10 })
                Text(squad.ownerUsername || '未知')
                  .fontSize(16)
                  .fontColor('#333333')
                  .flexGrow(1)
              }
              .width('100%')
              .margin({ bottom: 15 })

              // 加入按钮
              Row() {
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
            }
            .width('100%')
            .padding({ top: 20, right: 20, bottom: 20, left: 20 })
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .margin({ left: 20, right: 20 })
          }
        })
        
        // 加载更多指示器
        if (this.loading) {
          ListItem() {
            Row() {
              Text('加载中...')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ top: 20, bottom: 20 })
            .justifyContent(FlexAlign.Center)
          }
        }
        
        // 无更多数据提示
        if (this.noMoreData) {
          ListItem() {
            Row() {
              Text('无更多小队数据')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ top: 20, bottom: 20 })
            .justifyContent(FlexAlign.Center)
          }
        }
      }
      .height("100%")
      .onReachEnd(() => {
        this.loadMoreSquads()
      })
      .width('100%')
      .height('80%') // 调整高度，确保有足够空间
    }
    .width('100%')
    .height('90%')
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 我的小队页面内容组件
 */
@Component
struct MyTeamContent {
  // 状态变量：存储小队列表
  @State private squads: Array<SquadResponse> = []
  // 状态变量：是否正在加载
  @State private loading: boolean = true
  // 状态变量：错误信息
  @State private errorMessage: string = ''

  // 组件生命周期：组件创建时获取小队信息
  aboutToAppear() {
    this.loadSquads()
  }

  // 加载小队信息
  private async loadSquads() {
    this.loading = true
    try {
      // 调用获取已加入小队的方法
      const squads = await SquadService.getJoinedSquads()
      console.log('获取到的小队数据:', JSON.stringify(squads))
      this.squads = squads
    } catch (error) {
      console.error('加载小队信息失败:', error)
      this.errorMessage = '加载小队信息失败'
    } finally {
      this.loading = false
    }
  }

  // 退出小队
  private async leaveSquad(squadId?: number) {
    if (!squadId) {
      return
    }
    this.loading = true
    try {
      const result = await SquadService.leaveSquad(squadId)
      console.log('退出小队结果:', result)
      // 重新加载小队列表
      await this.loadSquads()
      // 显示成功提示
      this.errorMessage = result.message
      // 3秒后清除提示
      setTimeout(() => {
        this.errorMessage = ''
      }, 3000)
    } catch (error) {
      console.error('退出小队失败:', error)
      this.errorMessage = '退出小队失败'
      // 3秒后清除提示
      setTimeout(() => {
        this.errorMessage = ''
      }, 3000)
    } finally {
      this.loading = false
    }
  }

  build() {
    Column() {
      // 1. 页面标题
      Text('我的小队')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 40 })
        .fontColor('#333333')

      // 2. 加载状态
      if (this.loading) {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 20 })
      }

      // 3. 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4d4f')
          .margin({ bottom: 20 })
          .textAlign(TextAlign.Center)
      }

      // 4. 小队列表区域
      Row() {
        List({ space: 10 }) {
          ForEach(this.squads, (squad: SquadResponse) => {
            ListItem() {
              Column() {
                // 小队ID
                Row() {
                  Text('小队ID:')
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ right: 10 })
                  Text(squad.id?.toString() || '未知')
                    .fontSize(16)
                    .fontColor('#333333')
                }
                .width('100%')
                .margin({ bottom: 10 })

                // 小队名称
                Row() {
                  Text('小队名称:')
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ right: 10 })
                  Text(squad.name || '未知')
                    .fontSize(16)
                    .fontColor('#333333')
                    .flexGrow(1)
                }
                .width('100%')
                .margin({ bottom: 10 })

                // 成员ID列表
                Row() {
                  Text('成员ID:')
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ right: 10 })
                  Text(squad.memberIds?.join(', ') || '无')
                    .fontSize(16)
                    .fontColor('#333333')
                    .flexGrow(1)
                }
                .width('100%')
                .margin({ bottom: 15 })

                // 退出小队按钮
                Row() {
                  Button('退出小队')
                    .width('100%')
                    .height(40)
                    .backgroundColor('#ff4d4f')
                    .fontColor('#ffffff')
                    .fontSize(16)
                    .borderRadius(8)
                    .onClick(() => this.leaveSquad(squad.id))
                }
                .width('100%')
              }
              .width('100%')
              .padding({ top: 20, right: 20, bottom: 20, left: 20 })
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
            }
          })

          // 空状态
          if (!this.loading && this.squads.length === 0) {
            ListItem() {
              Text('暂无加入的小队')
                .fontSize(16)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .padding({ top: 40, bottom: 40 })
            }
          }
        }
        .width('100%')
        .height('100%')
      }
      .width('80%')
      .height('60%')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 聊天消息类型
 */
interface ChatMessage {
  id?: number;
  roomId?: number;
  senderId?: number;
  sender?: string;
  content?: string;
  timestamp?: string;
}

/**
 * 小队聊天信息类型
 */
interface SquadChatInfo {
  chatRoom: ChatRoomResponse | null;
  messages: Array<ChatMessage>;
  showChatList: boolean;
  loading: boolean;
}

/**
 * 小队天地页面内容组件
 */
@Component
struct SquadWorldContent {
  // 状态变量：存储小队列表
  @State private squads: Array<SquadResponse> = []
  // 状态变量：是否正在加载
  @State private loading: boolean = true
  // 状态变量：错误信息
  @State private errorMessage: string = ''
  // 状态变量：存储每个小队的聊天信息和显示状态
  @State private squadChatInfo: Map<number, SquadChatInfo> = new Map()
  // 状态变量：存储每个小队的点击计数，二维数组格式：[squadId, clickCount]
  @State private squadClickCount: Array<[number, number]> = []

  // 组件生命周期：组件创建时获取用户所在的小队列表
  aboutToAppear() {
    this.loadUserSquads()
  }

  // 加载用户所在的小队列表
  private async loadUserSquads() {
    this.loading = true
    try {
      // 调用获取已加入小队的方法
      const squads = await SquadService.getJoinedSquads()
      console.log('获取到的小队数据:', JSON.stringify(squads))
      this.squads = squads
      
      // 初始化每个小队的聊天信息状态和点击计数
      squads.forEach(squad => {
        if (squad.id) {
          // 初始化聊天信息状态
          this.squadChatInfo.set(squad.id, {
            chatRoom: null,
            messages: [],
            showChatList: false,
            loading: false
          })
          // 初始化点击计数为1，添加到二维数组
          this.squadClickCount.push([squad.id, 1])
        }
      })
    } catch (error) {
      console.error('加载小队信息失败:', error)
      this.errorMessage = '加载小队信息失败'
    } finally {
      this.loading = false
    }
  }

  // 获取小队的点击计数
  private getSquadClickCount(squadId: number): number {
    const index = this.squadClickCount.findIndex(item => item[0] === squadId)
    if (index !== -1) {
      return this.squadClickCount[index][1]
    }
    // 如果找不到，返回默认值1
    return 1
  }

  // 更新小队的点击计数
  private updateSquadClickCount(squadId: number): void {
    const index = this.squadClickCount.findIndex(item => item[0] === squadId)
    if (index !== -1) {
      // 点击计数加1
      this.squadClickCount[index][1] += 1
    } else {
      // 如果找不到，添加新的记录
      this.squadClickCount.push([squadId, 2])
    }
  }

  // 获取小队的聊天室信息并显示聊天列表
  private async getSquadChatRoom(squadId: number) {
    if (!squadId) return
    
    // 更新对应小队的加载状态
    const currentInfo = this.squadChatInfo.get(squadId)
    if (currentInfo) {
      this.squadChatInfo.set(squadId, {
        chatRoom: currentInfo.chatRoom,
        messages: currentInfo.messages,
        showChatList: currentInfo.showChatList,
        loading: true
      })
    }
    
    try {
      // 获取聊天室信息
      const chatRoom: ChatRoomResponse = await ChatService.getOrCreateRoomBySquad(squadId)
      console.log('获取到的聊天室信息:', JSON.stringify(chatRoom))
      
      // 获取聊天消息
      let messages: Array<ChatMessage> = []
      if (chatRoom.id) {
        const messageResponses = await ChatService.getMessagesByRoomId(chatRoom.id)
        console.log('获取到的聊天消息:', JSON.stringify(messageResponses))
        // 转换为ChatMessage类型
        messages = messageResponses.map(msg => ({
          id: msg.id,
          roomId: msg.roomId,
          senderId: msg.senderId,
          sender: msg.senderName,
          content: msg.content,
          timestamp: msg.timestamp
        } as ChatMessage))
      }
      
      // 更新对应小队的聊天信息
      const updatedInfo = this.squadChatInfo.get(squadId)
      if (updatedInfo) {
        this.squadChatInfo.set(squadId, {
          chatRoom: chatRoom,
          messages: messages,
          showChatList: true,
          loading: false
        })
      }
    } catch (error) {
      console.error('获取聊天室信息失败:', error)
      this.errorMessage = '获取聊天室信息失败'
      setTimeout(() => {
        this.errorMessage = ''
      }, 3000)
      
      // 更新对应小队的加载状态
      const errorInfo = this.squadChatInfo.get(squadId)
      if (errorInfo) {
        this.squadChatInfo.set(squadId, {
          chatRoom: errorInfo.chatRoom,
          messages: errorInfo.messages,
          showChatList: errorInfo.showChatList,
          loading: false
        })
      }
    }
  }

  build() {
    Column() {
      // 1. 页面标题
      Text('小队天地')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 40 })
        .fontColor('#333333')

      // 2. 加载状态
      if (this.loading) {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 20 })
      }

      // 3. 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4d4f')
          .margin({ bottom: 20 })
          .textAlign(TextAlign.Center)
      }

      // 4. 小队列表
      Column() {
        Text('我的小队')
          .fontSize(18)
          .fontColor('#333333')
          .margin({ bottom: 20 })
          .alignSelf(ItemAlign.Start)
          .margin({ left: '10%' })

        // 使用ForEach遍历用户所在的多个小队
        ForEach(this.squads, (squad: SquadResponse) => {
          Column() {
            Row() {
              Column() {
                // 小队名称
                Text(squad.name || '未知小队')
                  .fontSize(16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 8 })

                // 小队描述
                Text(squad.description || '无描述')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 12 })

                // 成员数量
                Text(`成员: ${squad.currentMembers || 0}/${squad.maxMembers || 0}`)
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .flexGrow(1)

              // 进入聊天室按钮
              Button('进入聊天室')
                .width(100)
                .height(36)
                .backgroundColor('#1890ff')
                .fontColor('#ffffff')
                .fontSize(14)
                .borderRadius(18)
                .onClick(() => {
                  const squadId = squad.id || 0
                  if (squadId > 0) {
                    this.updateSquadClickCount(squadId)
                  }
                  this.getSquadChatRoom(squadId)
                })
            }
            .width('80%')
            .padding({ top: 15, right: 15, bottom: 15, left: 15 })
            .backgroundColor('#f5f5f5')
            .borderRadius(8)
            .margin({ bottom: 15 })
            .alignItems(VerticalAlign.Center)

            // 聊天列表区域
            if (squad.id && this.squadChatInfo.get(squad.id)?.showChatList && this.getSquadClickCount(squad.id) % 2 === 0) {
              Column() {
                // 聊天列表标题
                Row() {
                  Text('聊天信息')
                    .fontSize(14)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Bold)
                  .flexGrow(1)
                }
                .width('100%')
                .margin({ bottom: 10 })

                // 加载状态
                if (this.squadChatInfo.get(squad.id)?.loading) {
                  Text('加载聊天信息中...')
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ bottom: 10 })
                } else if (this.squadChatInfo.get(squad.id)?.chatRoom) {
                  // 聊天室信息
                  Column() {
                    Text(`聊天室ID: ${this.squadChatInfo.get(squad.id)?.chatRoom?.id || '未知'}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ bottom: 5 })
                    Text(`创建时间: ${this.squadChatInfo.get(squad.id)?.chatRoom?.createdAt || '未知'}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ bottom: 5 })
                  }
                  .margin({ bottom: 10 })

                  // 消息列表（这里可以根据需要加载实际消息）
                  Column() {
                    Text('消息列表:')
                      .fontSize(14)
                      .fontColor('#333333')
                      .margin({ bottom: 5 })
                    if (this.squadChatInfo.get(squad.id)?.messages) {
                      if ((this.squadChatInfo.get(squad.id)!.messages as Array<ChatMessage>).length > 0) {
                        ForEach(this.squadChatInfo.get(squad.id)!.messages as Array<ChatMessage>, (message: ChatMessage) => {
                          Text(`${message.sender}: ${message.content}`)
                            .fontSize(14)
                            .fontColor('#666666')
                            .margin({ bottom: 3 })
                        })
                      } else {
                        Text('暂无消息')
                          .fontSize(14)
                          .fontColor('#999999')
                      }
                    } else {
                      Text('暂无消息')
                        .fontSize(14)
                        .fontColor('#999999')
                    }
                  }
                }
              }
              .width('80%')
              .padding({ top: 10, right: 15, bottom: 15, left: 15 })
              .backgroundColor('#e8f4ff')
              .borderRadius(8)
              .margin({ bottom: 15 })
              .alignSelf(ItemAlign.Center)
            }
          }
        })

        // 空状态
        if (!this.loading && this.squads.length === 0) {
          Text('暂无加入的小队')
            .fontSize(16)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .padding({ top: 40, bottom: 40 })
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}



/**
 * 个人中心页面内容组件
 */
@Component
struct MyPageContent {
  // 状态变量
  @State private userProfile: UserProfile = {}
  @State private isLoading: boolean = true
  @State private errorMessage: string = ''
  @State private friends: Array<FriendInfo> = []
  @State private securityInfo: AccountSecurity = {}
  @State private isFriendDropdownVisible: boolean = false

  // 组件生命周期：组件创建时获取用户信息
  aboutToAppear() {
    console.log("开始加载")
    this.loadUserInfo()
  }

  // 加载用户信息
  private async loadUserInfo() {
    this.isLoading = true
    console.log("开始加载")
    try {
      // 从后端获取详细个人资料
      console.log('开始调用getUserProfile()方法');
      const profile = await UserService.getUserProfile()
      console.log('getUserProfile()调用成功，返回数据:', JSON.stringify(profile));
      
      // 手动转换为UserProfile类型
      const userProfileData: UserProfile = {
        id: profile.id,
        username: profile.username,
        nickname: profile.nickname,
        avatar: profile.avatar,
        bio: profile.bio,
        gender: profile.gender,
        birthday: profile.birthday,
        location: profile.location
      }
      this.userProfile = userProfileData
      console.log('用户资料更新成功，当前用户:', this.userProfile.username);

      // 获取好友列表
      const friendsList = await UserService.getFriends()
      // 手动转换为FriendInfo数组类型
      this.friends = []
      for (let i = 0; i < friendsList.length; i++) {
        const friend = friendsList[i]
        const friendInfo: FriendInfo = {
          id: friend.id,
          username: friend.username,
          nickname: friend.nickname,
          avatar: friend.avatar,
          status: friend.status,
          addedAt: friend.addedAt
        }
        this.friends.push(friendInfo)
      }

      // 获取账号安全信息
      const security = await UserService.getAccountSecurity()
      // 手动转换为AccountSecurity类型
      const accountSecurity: AccountSecurity = {
        twoFactorEnabled: security.twoFactorEnabled,
        lastLogin: security.lastLogin,
        loginHistory: security.loginHistory
      }
      this.securityInfo = accountSecurity
    } catch (error) {
      console.error('Failed to load user info:', error)
      this.errorMessage = '加载用户信息失败'
      // 使用默认账号123信息
      const defaultUserProfile: UserProfile = {
        username: '111'
      }
      this.userProfile = defaultUserProfile
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      // 1. 页面标题
      Text('个人中心')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 40 })
        .fontColor('#333333')

      // 2. 加载状态
      if (this.isLoading) {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ bottom: 20 })
      }

      // 3. 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#ff4d4f')
          .margin({ bottom: 20 })
          .textAlign(TextAlign.Center)
      }

      // 4. 头像区域
      Row() {
        // 头像
        Stack() {
          if (this.userProfile.avatar) {
            Image(this.userProfile.avatar)
              .width(80)
              .height(80)
              .borderRadius(40)
          } else {
            Circle()
              .width(80)
              .height(80)
              .fill('#e5e5e5')
            Text(this.userProfile.nickname?.charAt(0) || '头')
              .fontSize(32)
              .fontColor('#999999')
          }
        }
        .margin({ right: 20 })

        Column() {
          Text(this.userProfile.username|| "111")
            .fontSize(18)
            .fontColor('#333333')
            .margin({ bottom: 8 })
          Text('点击查看个人资料')
            .fontSize(14)
            .fontColor('#999999')
        }
        .flexGrow(1)

        Image('common:ic_arrow_right')
          .width(20)
          .height(20)
          .margin({ right: 20 })
      }
      .width('100%')
      .padding({ top:20,right:20, bottom:20,left:20 })

      // 5. 账号安全
      Row() {
        Text('账号安全')
          .fontSize(16)
          .fontColor('#333333')
          .flexGrow(1)

        Image('common:ic_arrow_right')
          .width(20)
          .height(20)
          .margin({ right: 20 })
      }
      .width('100%')
      .padding({ top:20,right:20, bottom:20,left:20 })

      // 6. 好友
      Row() {
        Text(`好友 (${this.friends.length})`)
          .fontSize(16)
          .fontColor('#333333')
          .flexGrow(1)

        Image('common:ic_arrow_right')
          .width(20)
          .height(20)
          .margin({ right: 20 })
      }
      .width('100%')
      .padding({ top:20,right:20, bottom:20,left:20 })
      .onClick(() => {
        this.isFriendDropdownVisible = !this.isFriendDropdownVisible
      })

      // 好友下拉列表
      if (this.isFriendDropdownVisible) {
        Column() {
          ForEach(this.friends, (friend: FriendInfo) => {
            Row() {
              Stack() {
                if (friend.avatar) {
                  Image(friend.avatar)
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                } else {
                  Circle()
                    .width(40)
                    .height(40)
                    .fill('#e5e5e5')
                  Text(friend.nickname?.charAt(0) || '好')
                    .fontSize(16)
                    .fontColor('#999999')
                }
              }
              .margin({ right: 12 })

              Column() {
                Text(friend.nickname || friend.username || '未知')
                  .fontSize(14)
                  .fontColor('#333333')
                  .margin({ bottom: 4 })
                Text(friend.status || '在线')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)

              Text(friend.addedAt ? friend.addedAt.substring(0, 10) : '')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ right: 20 })
            }
            .width('100%')
            .padding({ top: 12, right: 20, bottom: 12, left: 20 })
            .backgroundColor('#f9f9f9')
          })

          if (this.friends.length === 0) {
            Row() {
              Text('暂无好友')
                .fontSize(14)
                .fontColor('#999999')
                .flexGrow(1)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 20, right: 20, bottom: 20, left: 20 })
            .backgroundColor('#f9f9f9')
          }
        }
        .width('100%')
        .margin({ left: 20, right: 20, bottom: 10 })
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,

        })
      }

      // 7. 偏好设置
      Row() {
        Text('偏好设置')
          .fontSize(16)
          .fontColor('#333333')
          .flexGrow(1)

        Image('common:ic_arrow_right')
          .width(20)
          .height(20)
          .margin({ right: 20 })
      }
      .width('100%')
      .padding({ top:20,right:20, bottom:20,left:20 })
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 组队大厅页面内容组件 - 用于兼容旧的页面结构
 */
@Component
struct DashboardPage {
  build() {
    TeamLobbyContent()
  }
}

/**
 * 个人中心页面内容组件 - 用于兼容旧的页面结构
 */
@Component
struct MyPage {
  build() {
    MyPageContent()
  }
}