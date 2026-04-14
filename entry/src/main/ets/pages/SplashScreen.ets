import router from '@ohos.router';

@Entry
@Component
struct SplashScreen {
  @State isLoading: boolean = true;
  @State textOpacity: number = 0;
  @State textScale: number = 0.5;
  @State offsetX: number = 150; // One字初始从右侧150位置进入（屏幕外）
  @State funOffsetX: number = 0; // Fun字初始在屏幕正中间
  @State showOne: boolean = false;
  @State oneOpacity: number = 0; // One字独立的透明度，实现平滑出现
  
  // 背景颜色层状态
  @State bgOpacity1: number = 0.5;
  @State bgOpacity2: number = 0.5;
  @State bgOpacity3: number = 0.5;
  @State bgScale1: number = 1;
  @State bgScale2: number = 1;
  @State bgScale3: number = 1;
  @State bgTranslateX1: number = 0;
  @State bgTranslateY1: number = 0;
  @State bgTranslateX2: number = 50;
  @State bgTranslateY2: number = -50;
  @State bgTranslateX3: number = -50;
  @State bgTranslateY3: number = 50;

  aboutToAppear() {
    // 启动文字动画
    this.startTextAnimation();
    // 启动背景色交融动画
    this.startBackgroundBlendAnimation();
    // 5秒后执行退出动画
    setTimeout(() => {
      this.exitAnimation();
    }, 5000);
  }

  // 启动文字渐入+缩放动画
  startTextAnimation() {
    // 重置Fun字初始状态，确保动画开始位置正确
    this.funOffsetX = 0;
    
    // 第一阶段：Fun文字从中间淡入+缩放，保持位置
    animateTo({
      duration:2000,
      curve: Curve.Linear, // 使用线性曲线，避免先快后慢
      delay: 0,
      onFinish: () => {
        // 第二阶段：Fun字平滑向左移动，同时One文字从右侧滑入并淡入
        this.showOne = true;
        // 初始化One字的状态
        this.offsetX = 150;
        this.oneOpacity = 0;
        animateTo({
          duration: 1500,
          curve: Curve.Linear, // 使用线性曲线，保持匀速
          delay: 0
        }, () => {
          this.funOffsetX = -80; // 调整移动距离，适应One字出现后的布局变化
          this.offsetX = 80; // One字移动到Fun字右侧
          this.oneOpacity = 1; // One字平滑淡入
        });
      }
    }, () => {
      // 第一阶段：淡入+缩放，不调整位置（避免冲突）
      this.textOpacity = 1;
      this.textScale = 1.5;
    });
  }

  // 启动背景色交融动画
  startBackgroundBlendAnimation() {
    // 颜色交融动画循环
    const runAnimation = () => {
      // 第一层动画
      animateTo({
        duration: 200,
        curve: Curve.EaseInOut,
        onFinish: () => {
          // 第二层动画
          animateTo({
            duration: 1000,
            curve: Curve.EaseInOut,
            onFinish: () => {
              // 第三层动画
              animateTo({
                duration: 2000,
                curve: Curve.EaseInOut,
                onFinish: () => {
                  // 循环动画
                  runAnimation();
                }
              }, () => {
                this.bgOpacity3 = Math.random() * 0.3 + 0.3;
                this.bgScale3 = Math.random() * 0.6 + 0.9; // 统一缩放范围：0.9-1.5
                this.bgTranslateX3 = Math.random() * 100 - 50;
                this.bgTranslateY3 = Math.random() * 100 - 50;
              });
            }
          }, () => {
            this.bgOpacity2 = Math.random() * 0.3 + 0.3;
            this.bgScale2 = Math.random() * 0.6 + 0.9; // 统一缩放范围：0.9-1.5
            this.bgTranslateX2 = Math.random() * 100 - 50;
            this.bgTranslateY2 = Math.random() * 100 - 50;
          });
        }
      }, () => {
        this.bgOpacity1 = Math.random() * 0.3 + 0.3;
        this.bgScale1 = Math.random() * 0.6 + 0.9; // 统一缩放范围：0.9-1.5
        this.bgTranslateX1 = Math.random() * 100 - 50;
        this.bgTranslateY1 = Math.random() * 100 - 50;
      });
    };
    
    // 启动动画
    runAnimation();
  }

  // 退出动画 - 增强文字消失效果
  exitAnimation() {
    animateTo({
      duration: 1000,
      curve: Curve.EaseInOut,
      delay: 0,
      onFinish: () => {
        // 动画完成后再跳转
        router.replaceUrl({
          url: 'pages/Index'
        }).catch((error: Error) => {
          console.error('Error navigating to Index page:', error);
        });
      }
    }, () => {
      // 文字消失动画组合效果
      this.textOpacity = 0;           // 完全淡出
      this.textScale = 2;             // 放大效果增强
      
      // 背景同时淡出
      this.bgOpacity1 = 0;
      this.bgOpacity2 = 0;
      this.bgOpacity3 = 0;
    });
  }

  build() {
    Stack() {
      // 背景层 - 多层颜色交融
      // 第一层：红色
      Column()
        .height('150%')
        .width('150%')
        .backgroundColor('#FF6B6B')
        .opacity(this.bgOpacity1)
        .scale({ x: this.bgScale1, y: this.bgScale1 })
        .translate({ x: this.bgTranslateX1, y: this.bgTranslateY1 })
      
      // 第二层：青色
      Column()
        .height('150%')
        .width('150%')
        .backgroundColor('#4ECDC4')
        .opacity(this.bgOpacity2)
        .scale({ x: this.bgScale2, y: this.bgScale2 })
        .translate({ x: this.bgTranslateX2, y: this.bgTranslateY2 })
      
      // 第三层：黄色
      Column()
        .height('150%')
        .width('150%')
        .backgroundColor('#FFD93D')
        .opacity(this.bgOpacity3)
        .scale({ x: this.bgScale3, y: this.bgScale3 })
        .translate({ x: this.bgTranslateX3, y: this.bgTranslateY3 })
      
      // 文字内容层
      Column() {
        if (this.isLoading) {
          Column() {
            // 主标题容器 - 使用Stack确保Fun位置不受One影响
            Stack() {
              // Fun文字 - 始终居中，通过translate控制位置
              Text('Fun')
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .opacity(this.textOpacity)
                .scale({ x: this.textScale, y: this.textScale })
                .translate({ x: this.funOffsetX })

              // One文字 - 从右侧滑入，通过translate控制位置
              if (this.showOne) {
                Text('One')
                  .fontSize(48)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .opacity(this.oneOpacity)
                  .translate({ x: this.offsetX })
                  .scale({ x: this.textScale, y: this.textScale })
              }
            }
            .width('100%')
            .height(100)

            // 应用标语
            Text('Have Fun, Be One!')
              .fontSize(18)
              .fontColor('#FFFFFF')
              .margin({ top: 20 })
              .opacity(this.textOpacity)
          }
        }
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
    .width('100%')
  }
}