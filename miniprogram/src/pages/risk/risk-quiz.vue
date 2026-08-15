<template>
  <view class="rq">
    <view v-if="!finished" class="rq-prog">
      <text class="rq-label">风险承受力测评</text>
      <text class="rq-num">{{ idx + 1 }} / {{ list.length }}</text>
    </view>
    <ProgressBar v-if="!finished" :read="idx" :total="list.length" />

    <view v-if="!finished && cur" class="rq-card cx-card">
      <text class="rq-q">{{ cur.question }}</text>
      <view class="rq-options">
        <view
          v-for="(opt, i) in cur.options"
          :key="i"
          class="opt"
          :class="{ on: picked === i }"
          @tap="pick(i)"
        >
          <text class="opt-text">{{ opt.text }}</text>
          <text class="opt-check" v-if="picked === i">✓</text>
        </view>
      </view>
      <view
        class="cx-btn-primary rq-next"
        :class="{ disabled: picked < 0 }"
        @tap="next"
      >{{ idx + 1 < list.length ? '下一题 →' : '查看结果' }}</view>
    </view>

    <view v-if="finished" class="result">
      <view class="result-card cx-card">
        <text class="result-emoji">{{ meta.emoji }}</text>
        <text class="result-title">{{ meta.title }}</text>
        <text class="result-desc">{{ meta.desc }}</text>
        <view class="result-alloc">
          <text class="ra-label">建议股债配置（教学参考）</text>
          <text class="ra-val">{{ allocation }}</text>
        </view>
        <view class="result-tip">
          <text class="rt-label">💡 小贴士</text>
          <text class="rt-body">这是基于你答题的画像参考，会随年龄、收入、心态变化。没有标准答案，认清自己比追求高收益更重要。</text>
        </view>
      </view>
      <view class="result-actions">
        <view class="cx-btn-outline result-btn" @tap="restart">重新测评</view>
        <view class="cx-btn-primary result-btn" @tap="back">完成</view>
      </view>
      <Disclaimer variant="plain" title="教学说明" icon="💡" text="测评结果仅供自我认知参考，不构成具体资产配置建议。实际决策请结合自身情况并咨询专业人士。" />
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import ProgressBar from '@/components/ProgressBar.vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { getRiskQuiz } from '@/utils/content'

const app = useAppStore()
const list = getRiskQuiz()
const idx = ref(0)
const picked = ref(-1)
const scores = ref([])
const finished = ref(false)

const cur = computed(() => list[idx.value] || null)

const totalScore = computed(() => scores.value.reduce((a, b) => a + b, 0))
const type = computed(() => {
  const s = totalScore.value
  if (s <= 6) return 'conservative'
  if (s <= 13) return 'balanced'
  return 'aggressive'
})
const meta = computed(() => app.riskProfileMeta(type.value))
const allocation = computed(() => app.riskAllocation(type.value))

function pick(i) {
  picked.value = i
}
function next() {
  if (picked.value < 0) return
  scores.value[idx.value] = cur.value.options[picked.value].score
  if (idx.value + 1 < list.length) {
    idx.value += 1
    picked.value = -1
  } else {
    app.saveRiskProfile(type.value)
    finished.value = true
  }
}
function restart() {
  idx.value = 0
  picked.value = -1
  scores.value = []
  finished.value = false
}
function back() {
  uni.navigateBack({ delta: 1, fail: () => uni.switchTab({ url: '/pages/simulation/simulation' }) })
}
</script>

<style lang="scss" scoped>
.rq {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.rq-prog {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.rq-label {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.rq-num {
  font-size: $fs-sm;
  color: $ink2;
}
.rq-card {
  padding: 32rpx;
  margin-top: 28rpx;
}
.rq-q {
  display: block;
  font-size: $fs-lg;
  font-weight: 700;
  color: $ink;
  line-height: 1.5;
  margin-bottom: 28rpx;
}
.rq-options {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}
.opt {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx;
  border: 2rpx solid $line;
  border-radius: $radius-md;
  background: $card;
}
.opt.on {
  border-color: $primary;
  background: $primarySoft;
}
.opt-text {
  flex: 1;
  font-size: $fs-base;
  color: $ink;
  line-height: 1.5;
}
.opt-check {
  color: $primary;
  font-weight: 800;
  font-size: 32rpx;
}
.rq-next {
  margin-top: 32rpx;
}
.rq-next.disabled {
  opacity: 0.4;
}
.result {
  margin-top: 28rpx;
}
.result-card {
  padding: 48rpx 32rpx;
  text-align: center;
}
.result-emoji {
  font-size: 120rpx;
  display: block;
}
.result-title {
  display: block;
  font-size: $fs-xl;
  font-weight: 800;
  color: $primary;
  margin: 16rpx 0 8rpx;
}
.result-desc {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
  margin-bottom: 28rpx;
}
.result-alloc {
  background: $primarySoft;
  border-radius: $radius-md;
  padding: 24rpx;
  margin-bottom: 24rpx;
}
.ra-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-bottom: 8rpx;
}
.ra-val {
  font-size: $fs-md;
  font-weight: 700;
  color: $primary;
}
.result-tip {
  background: #f6f1ea;
  border-radius: $radius-md;
  padding: 24rpx;
  text-align: left;
}
.rt-label {
  display: block;
  font-size: $fs-xs;
  font-weight: 700;
  color: $ink2;
  margin-bottom: 8rpx;
}
.rt-body {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
}
.result-actions {
  display: flex;
  gap: 20rpx;
  margin: 28rpx 0;
}
.result-btn {
  flex: 1;
}
</style>
