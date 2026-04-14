/**
 * EntryAbility - 应用入口能力组件
 * 
 * 功能说明：
 * 1. 管理应用的完整生命周期
 * 2. 创建和管理应用主窗口
 * 3. 加载应用初始页面
 * 4. 处理系统事件和应用状态切换
 * 
 * 架构位置：
 * - 配置在 module.json5 中作为 mainElement，是应用的主入口
 * - 连接系统与应用UI界面的桥梁
 * - 控制应用的启动、运行和退出流程
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

// 日志域标识，用于区分不同模块的日志
const DOMAIN = 0x0000;

/**
 * EntryAbility类 - 继承自UIAbility，实现应用入口能力
 */
export default class EntryAbility extends UIAbility {
  /**
   * 生命周期方法：应用初始化
   * 
   * 触发时机：
   * - 应用第一次启动时调用
   * - 仅调用一次
   * 
   * 参数说明：
   * @param want - 包含启动原因、参数等信息
   * @param launchParam - 包含启动方式、启动来源等信息
   */
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // 设置应用颜色模式为未设置状态，跟随系统
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      // 记录设置颜色模式失败的日志
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    // 记录应用初始化完成日志
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  /**
   * 生命周期方法：应用销毁
   * 
   * 触发时机：
   * - 应用完全退出时调用
   * - 仅调用一次
   * 
   * 功能：
   * - 释放应用资源
   * - 清理应用状态
   */
  onDestroy(): void {
    // 记录应用销毁日志
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  /**
   * 生命周期方法：窗口创建
   * 
   * 触发时机：
   * - 应用启动时创建主窗口后调用
   * - 每个UIAbility实例对应一个窗口
   * 
   * 参数说明：
   * @param windowStage - 窗口舞台对象，用于管理应用UI
   * 
   * 核心功能：
   * - 加载应用初始页面
   * - 配置窗口属性
   */
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 记录窗口创建日志
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 加载应用初始页面 - SplashScreen
    // 参数1：页面路径，对应main_pages.json中的配置
    // 参数2：加载结果回调函数
    windowStage.loadContent('pages/SplashScreen', (err) => {
      // 处理页面加载失败情况
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      // 记录页面加载成功日志
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  /**
   * 生命周期方法：窗口销毁
   * 
   * 触发时机：
   * - 应用窗口关闭时调用
   * 
   * 功能：
   * - 释放窗口相关资源
   * - 清理UI相关状态
   */
  onWindowStageDestroy(): void {
    // 记录窗口销毁日志
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  /**
   * 生命周期方法：应用切换到前台
   * 
   * 触发时机：
   * - 应用从后台切换到前台显示时调用
   * - 用户点击应用图标或切换应用时触发
   */
  onForeground(): void {
    // 记录应用切换到前台日志
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  /**
   * 生命周期方法：应用切换到后台
   * 
   * 触发时机：
   * - 应用从前台切换到后台运行时调用
   * - 用户按Home键或切换到其他应用时触发
   */
  onBackground(): void {
    // 记录应用切换到后台日志
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}