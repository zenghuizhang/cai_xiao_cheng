<template>
  <view class="cr">
    <view class="cr-hero cx-card">
      <text class="cr-emoji">📉</text>
      <text class="cr-title">暴跌演练</text>
      <text class="cr-sub">用一笔虚拟本金，提前「经历」一次大跌。真到了那天，你才不会慌。</text>
    </view>

    <view v-if="step < days.length" class="cr-stage cx-card">
      <view class="stage-head">
        <text class="stage-day">第 {{ step + 1 }} 天 / 共 {{ days.length }} 天</text>
        <text class="stage-emoji">{{ days[step].emoji }}</text>
      </view>

      <view class="port">
        <text class="port-label">虚拟账户</text>
        <text class="port-val">{{ formatYuan(curValue, 2) }}</text>
        <text class="port-pnl" :class="{ neg: curPnl < 0, pos: curPnl > 0 }">
          {{ formatPercent(curPnl) }}
        </text>
      </view>

      <view class="bar-wrap">
        <view class="bar-fill" :style="{ width: barWidth + '%' }"></view>
      </view>

      <text class="stage-news">{{ days[step].news }}</text>
      <text class="stage-mood">{{ days[step].mood }}</text>

      <view class="cx-btn-primary stage-next" @tap="advance">
        {{ step + 1 < days.length ? '硬扛到下一天 →' : '看看结局' }}
      </view>
    </view>

    <view v-else class="cr-result cx-card">
      <text class="res-emoji">{{ curPnl < 0 ? '😰' : '😌' }}</text>
      <text class="res-title">你扛过来了</text>
      <text class="res-stat">从 {{ formatYuan(principal, 0) }} 到 {{ formatYuan(curValue, 2) }}（{{ formatPercent(curPnl) }}）</text>
      <view class="res-takeaway">
        <text class="tk-label">💡 这就是暴跌教你的事</text>
        <text class="tk-body">账户浮亏不等于真实亏损——只要你没卖，它就只是数字在跳。多数人在最恐慌的那天割肉，把浮亏变成实亏，然后错过随后的反弹。提前演练过，真遇到时你才拿得住。</text>
      </view>
      <view v-if="firstTime" class="res-first">🎓 首次完成暴跌演练，已记录到你的成长档案</view>
      <Disclaimer variant="warn" title="重要提示" icon="⚠️" text="本演练为假设性教学场景，涨跌幅为设定值。真实市场波动更剧烈、更久，可能造成真实亏损。不构成「持有就能回本」的承诺或投资建议。" />
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { formatYuan, formatPercent } from '@/utils/format'

const app = useAppStore()
const principal = 100000
const firstTime = ref(false)

// 假设性暴跌行情（教学设定）
const days = [
  { emoji: '🌤️', chg: -0.03, news: '市场高开低走，分析师说「正常调整」。', mood: '你觉得：小波动而已，不慌。' },
  { emoji: '🌧️', chg: -0.05, news: '连跌两天，财经大V开始喊「危机来了」。', mood: '你有点坐不住了，反复打开App。' },
  { emoji: '⛈️', chg: -0.08, news: '恐慌蔓延，单日重挫，热搜全是「暴跌」。', mood: '手心出汗，想割肉又不甘心。' },
  { emoji: '🌩️', chg: -0.06, news: '还在跌，身边有人说「已经清仓了」。', mood: '你开始怀疑自己，到底该不该跑？' },
  { emoji: '🌫️', chg: 0.02, news: '跌势放缓，市场悄悄企稳。', mood: '如果你扛到这里，最坏的时刻已过去。' },
  { emoji: '☀️', chg: 0.05, news: '反弹开启，前期跌幅收回一半。', mood: '恐慌时卖出的人，已经错过了回血。' },
]

const step = ref(0)
const curValue = computed(() => {
  let v = principal
  for (let i = 0; i <= step.value; i++) v = v * (1 + days[i].chg)
  return v
})
const curPnl = computed(() => (curValue.value / principal - 1) * 100)
const barWidth = computed(() => Math.max(8, Math.min(100, (curValue.value / principal) * 100)))

function advance() {
  if (step.value < days.length - 1) {
    step.value += 1
  } else {
    // 走完最后一天 → 进入结果
    firstTime.value = app.markCrash()
    step.value = days.length
  }
}
</script>

<style lang="scss" scoped>
.cr {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.cr-hero {
  padding: 36rpx 32rpx;
  text-align: center;
  margin-bottom: 24rpx;
  background: linear-gradient(135deg, #fff0e6, $card);
}
.cr-emoji {
  font-size: 80rpx;
  display: block;
}
.cr-title {
  display: block;
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
  margin: 12rpx 0 8rpx;
}
.cr-sub {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
}
.cr-stage {
  padding: 32rpx;
  margin-bottom: 24rpx;
}
.stage-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}
.stage-day {
  font-size: $fs-sm;
  color: $ink2;
  font-weight: 600;
}
.stage-emoji {
  font-size: 48rpx;
}
.port {
  text-align: center;
  margin-bottom: 24rpx;
}
.port-label {
  font-size: $fs-xs;
  color: $ink2;
  display: block;
}
.port-val {
  display: block;
  font-size: 56rpx;
  font-weight: 800;
  color: $ink;
  line-height: 1.2;
  margin: 8rpx 0;
}
.port-pnl {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink3;
}
.port-pnl.neg {
  color: $danger;
}
.port-pnl.pos {
  color: $success;
}
.bar-wrap {
  height: 16rpx;
  background: $line;
  border-radius: $radius-pill;
  overflow: hidden;
  margin-bottom: 24rpx;
}
.bar-fill {
  height: 100%;
  background: linear-gradient(90deg, $primary, #ffb37a);
  transition: width 0.4s ease;
}
.stage-news {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
  background: #f6f1ea;
  border-radius: $radius-md;
  padding: 20rpx;
  margin-bottom: 16rpx;
}
.stage-mood {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  line-height: $lh-base;
  margin-bottom: 28rpx;
}
.stage-next {
  width: 100%;
}
.cr-result {
  padding: 40rpx 32rpx;
  text-align: center;
}
.res-emoji {
  font-size: 96rpx;
  display: block;
}
.res-title {
  display: block;
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
  margin: 16rpx 0 12rpx;
}
.res-stat {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin-bottom: 28rpx;
}
.res-takeaway {
  background: $primarySoft;
  border-radius: $radius-md;
  padding: 24rpx;
  text-align: left;
  margin-bottom: 24rpx;
}
.tk-label {
  display: block;
  font-size: $fs-xs;
  font-weight: 700;
  color: $primary;
  margin-bottom: 8rpx;
}
.tk-body {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
}
.res-first {
  font-size: $fs-sm;
  color: $success;
  font-weight: 600;
  margin-bottom: 24rpx;
}
</style>
