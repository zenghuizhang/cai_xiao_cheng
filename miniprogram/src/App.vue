<script setup>
import { onLaunch } from '@dcloudio/uni-app'
import { useAppStore } from './store/app'
import { useUserStore } from './store/user'
import { getProgress } from './utils/storage'

onLaunch(() => {
  // 同步判断引导页状态，避免返回用户看到引导页闪烁。
  // 进度统一存在 KEYS.PROGRESS（'cxch_progress'），onboarding_done 是其字段。
  let onboardingDone = false
  try {
    onboardingDone = !!getProgress().onboarding_done
  } catch (e) {}
  if (!onboardingDone) {
    uni.reLaunch({ url: '/pages/onboarding/onboarding' })
  }
  // 初始化 store：app.init 同步恢复本地进度；user.init 异步校验登录态/拉云端进度。
  try {
    const app = useAppStore()
    app.init()
  } catch (e) {
    console.error('app init', e)
  }
  try {
    const user = useUserStore()
    user.init().catch((e) => console.error('user init', e))
  } catch (e) {
    console.error('user init', e)
  }
})
</script>

<style lang="scss">
/* 全局样式 */
page {
  background-color: $cream;
  color: $ink;
  font-size: $fs-base;
  line-height: $lh-base;
  font-family: -apple-system, 'PingFang SC', 'Helvetica Neue', Helvetica,
    sans-serif;
}

/* 通用卡片 */
.cx-card {
  background: $card;
  border-radius: $radius-lg;
  border: 1rpx solid $line;
  box-shadow: $shadow-card;
}

/* 主按钮 */
.cx-btn-primary {
  background: $primary;
  color: #fff;
  border-radius: $radius-pill;
  font-weight: 700;
  text-align: center;
  font-size: $fs-md;
  height: 96rpx;
  line-height: 96rpx;
  border: none;
}
.cx-btn-primary::after {
  border: none;
}

/* 次按钮 */
.cx-btn-outline {
  background: $card;
  color: $ink;
  border: 2rpx solid $line;
  border-radius: $radius-pill;
  font-weight: 700;
  font-size: $fs-md;
  height: 92rpx;
  line-height: 88rpx;
}
.cx-btn-outline::after {
  border: none;
}

/* 风险提示块 */
.cx-warn {
  background: $dangerSoft;
  border-left: 6rpx solid $danger;
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
  color: $ink;
  font-size: $fs-sm;
  line-height: 1.7;
}

/* 要点引用块 */
.cx-point {
  border-left: 6rpx solid $success;
  background: $successSoft;
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
}

/* 安全区域底部留白 */
.safe-bottom {
  padding-bottom: calc(env(safe-area-inset-bottom) + 20rpx);
}
</style>
