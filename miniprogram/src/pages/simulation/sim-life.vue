<template>
  <view class="sl">
    <!-- 无 id：列出全部模拟场景 -->
    <view v-if="!sim" class="sl-list">
      <text class="sl-list-title">🎭 历史场景模拟</text>
      <text class="sl-list-sub">回到真实历史时刻，你会怎么选？看看不同选择的结局。</text>
      <view
        v-for="s in all"
        :key="s.id"
        class="sl-item cx-card"
        @tap="open(s.id)"
      >
        <view class="sl-item-top">
          <text class="sl-era">{{ s.era_year }}</text>
          <text class="sl-done" v-if="doneSet.has(s.id)">已体验 ✓</text>
        </view>
        <text class="sl-item-title">{{ s.title }}</text>
        <text class="sl-item-bg">{{ s.background }}</text>
        <text class="sl-go">进入推演 ›</text>
      </view>
      <Disclaimer variant="plain" title="教学说明" icon="💡" text="历史场景为假设性推演，收益率为教学设定，不代表当时真实回报或对未来预测。" />
    </view>

    <!-- 有 id：场景详情 -->
    <view v-else class="sl-detail">
      <view class="sl-hero">
        <text class="sl-hero-year">{{ sim.era_year }} 年</text>
        <text class="sl-hero-title">{{ sim.title }}</text>
        <text class="sl-hero-amount">手头闲钱 {{ formatYuan(sim.initial_amount, 0) }}</text>
      </view>

      <view class="sl-bg cx-card">
        <text class="sl-bg-label">📜 背景</text>
        <text class="sl-bg-text">{{ sim.background }}</text>
      </view>

      <text class="sl-ask">你会怎么放这笔钱？</text>

      <view
        v-for="opt in sim.options"
        :key="opt.key"
        class="opt"
        :class="optClass(opt.key)"
        @tap="choose(opt.key)"
      >
        <view class="opt-row">
          <text class="opt-emoji">{{ opt.emoji }}</text>
          <text class="opt-text">{{ opt.text }}</text>
        </view>
        <view v-if="revealed && opt.key === picked" class="opt-result">
          <text class="opt-pnl" :class="{ pos: opt.pnl_pct >= 0, neg: opt.pnl_pct < 0 }">
            收益 {{ formatPercent(opt.pnl_pct) }}
          </text>
          <text class="opt-outcome">{{ opt.outcome }}</text>
          <view class="opt-takeaway">
            <text class="tk-label">💡 启示</text>
            <text class="tk-body">{{ opt.takeaway }}</text>
          </view>
        </view>
      </view>

      <view v-if="revealed" class="sl-actions">
        <view class="cx-btn-outline sl-btn" @tap="reset">重新选</view>
        <view class="cx-btn-primary sl-btn" @tap="back">完成</view>
      </view>

      <Disclaimer v-if="revealed" variant="plain" title="教学说明" icon="💡" text="每种结局都是教学设定，真实历史中收益因时点、品种而异。不构成投资建议。" />
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { getSimulations, getSimulation } from '@/utils/content'
import { formatYuan, formatPercent } from '@/utils/format'

const app = useAppStore()
const id = ref('')
const sim = computed(() => (id.value ? getSimulation(id.value) : null))
const all = getSimulations()
const picked = ref('')
const revealed = ref(false)

const doneSet = computed(() => new Set(Object.keys(app.progress.sim_records || {})))

onLoad((options) => {
  id.value = options.id || ''
})
onShow(() => {
  picked.value = ''
  revealed.value = false
})

function optClass(key) {
  if (!revealed.value) return picked.value === key ? 'on' : ''
  if (key === picked.value) return 'active'
  return 'dim'
}
function choose(key) {
  if (revealed.value) return
  picked.value = key
  revealed.value = true
  const opt = sim.value.options.find((o) => o.key === key)
  app.recordSim(sim.value.id, key, opt ? opt.pnl_pct : 0)
}
function reset() {
  picked.value = ''
  revealed.value = false
}
function open(simId) {
  uni.navigateTo({ url: `/pages/simulation/sim-life?id=${simId}` })
}
function back() {
  uni.navigateBack({ delta: 1, fail: () => uni.switchTab({ url: '/pages/simulation/simulation' }) })
}
</script>

<style lang="scss" scoped>
.sl {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
/* 列表 */
.sl-list-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
  display: block;
}
.sl-list-sub {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin: 8rpx 0 24rpx;
  line-height: $lh-base;
}
.sl-item {
  padding: 28rpx;
  margin-bottom: 20rpx;
}
.sl-item-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.sl-era {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 700;
  background: $primarySoft;
  padding: 4rpx 16rpx;
  border-radius: $radius-pill;
}
.sl-done {
  font-size: $fs-xs;
  color: $success;
}
.sl-item-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
}
.sl-item-bg {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: 1.6;
  margin: 12rpx 0 16rpx;
}
.sl-go {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 600;
}
/* 详情 */
.sl-hero {
  text-align: center;
  padding: 32rpx 0 24rpx;
}
.sl-hero-year {
  font-size: 80rpx;
  font-weight: 800;
  color: $primary;
  display: block;
  line-height: 1.1;
}
.sl-hero-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
  margin: 8rpx 0;
}
.sl-hero-amount {
  font-size: $fs-sm;
  color: $ink2;
}
.sl-bg {
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.sl-bg-label {
  font-size: $fs-xs;
  font-weight: 700;
  color: $ink2;
  display: block;
  margin-bottom: 8rpx;
}
.sl-bg-text {
  font-size: $fs-base;
  color: $ink;
  line-height: $lh-base;
}
.sl-ask {
  display: block;
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  margin-bottom: 20rpx;
}
.opt {
  background: $card;
  border: 2rpx solid $line;
  border-radius: $radius-md;
  padding: 24rpx;
  margin-bottom: 20rpx;
}
.opt.on,
.opt.active {
  border-color: $primary;
  background: $primarySoft;
}
.opt.dim {
  opacity: 0.5;
}
.opt-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.opt-emoji {
  font-size: 40rpx;
}
.opt-text {
  flex: 1;
  font-size: $fs-base;
  color: $ink;
  font-weight: 600;
}
.opt-result {
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid $line;
}
.opt-pnl {
  display: block;
  font-size: $fs-md;
  font-weight: 800;
  margin-bottom: 12rpx;
}
.opt-pnl.pos {
  color: $success;
}
.opt-pnl.neg {
  color: $danger;
}
.opt-outcome {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
  margin-bottom: 16rpx;
}
.opt-takeaway {
  background: $card;
  border-radius: $radius-md;
  padding: 20rpx;
}
.tk-label {
  font-size: $fs-xs;
  font-weight: 700;
  color: $primary;
  display: block;
  margin-bottom: 6rpx;
}
.tk-body {
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
}
.sl-actions {
  display: flex;
  gap: 20rpx;
  margin: 16rpx 0 24rpx;
}
.sl-btn {
  flex: 1;
}
</style>
