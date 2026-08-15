<template>
  <view class="qz">
    <view class="qz-prog">
      <text class="qz-prog-label">{{ chapter ? chapter.title : '闯关测验' }}</text>
      <text class="qz-prog-num">{{ answered }} / {{ list.length }}</text>
    </view>
    <ProgressBar :read="answered" :total="list.length" />

    <!-- 题目区 -->
    <view v-if="cur && !finished" class="qz-card cx-card">
      <view class="qz-q-head">
        <text class="qz-pts">+{{ cur.points }} 积分</text>
        <text class="qz-q-no">第 {{ idx + 1 }} 题</text>
      </view>
      <text class="qz-question">{{ cur.question }}</text>
      <view class="qz-options">
        <view
          v-for="(opt, i) in cur.options"
          :key="i"
          class="opt"
          :class="optClass(i)"
          @tap="choose(i)"
        >
          <text class="opt-letter">{{ letter(i) }}</text>
          <text class="opt-text">{{ opt }}</text>
          <text v-if="locked && i === cur.answer_index" class="opt-flag">✓</text>
          <text v-else-if="locked && i === picked" class="opt-flag wrong">✕</text>
        </view>
      </view>

      <view v-if="locked" class="qz-explain">
        <text class="ex-emoji">{{ isRight ? '🎉' : '💡' }}</text>
        <view class="ex-body">
          <text class="ex-reply">{{ isRight ? cur.right_reply : cur.wrong_reply }}</text>
          <text class="ex-text">{{ cur.explanation }}</text>
        </view>
      </view>

      <view
        v-if="locked"
        class="cx-btn-primary qz-next"
        @tap="next"
      >{{ idx + 1 < list.length ? '下一题 →' : '查看结果' }}</view>
    </view>

    <!-- 结果区 -->
    <view v-if="finished" class="result">
      <view class="result-card cx-card">
        <text class="result-emoji">{{ passed ? '🏆' : '💪' }}</text>
        <text class="result-title">{{ passed ? '通关成功！' : '差一点点' }}</text>
        <text class="result-stat">{{ correct }} / {{ list.length }} 题正确（{{ rateText }}）</text>
        <view v-if="passed" class="result-earned">
          <text>认知积分 +{{ earned }} 🍊</text>
          <text class="result-unlock">已解锁下一章 + 认知果实 🎉</text>
        </view>
        <text v-else class="result-hint">答对 80% 即可通关，再试一次就稳了！</text>
        <Disclaimer variant="plain" title="提示" icon="💡" text="测验仅用于巩固学习，不构成任何投资建议。" />
      </view>
      <view class="result-actions">
        <view class="cx-btn-outline result-btn" @tap="restart">再测一次</view>
        <view class="cx-btn-primary result-btn" @tap="back">返回章节</view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import ProgressBar from '@/components/ProgressBar.vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { getChapter, getQuizzesByChapter } from '@/utils/content'

const app = useAppStore()
const chapterId = ref('')
const chapter = ref(null)
const list = ref([])
const idx = ref(0)
const picked = ref(-1)
const locked = ref(false)
const finished = ref(false)
const correct = ref(0)

onLoad((options) => {
  chapterId.value = options.chapter
  chapter.value = getChapter(options.chapter)
  list.value = getQuizzesByChapter(options.chapter)
})

const cur = computed(() => list.value[idx.value] || null)
const answered = computed(() => (finished.value ? list.value.length : idx.value + (locked.value ? 1 : 0)))
const isRight = computed(() => locked.value && picked.value === cur.value.answer_index)
const passed = computed(() => list.value.length > 0 && correct.value / list.value.length >= 0.8)
const earned = ref(0)
const rateText = computed(() => (list.value.length ? Math.round((correct.value / list.value.length) * 100) : 0) + '%')

function letter(i) {
  return ['A', 'B', 'C', 'D', 'E'][i] || ''
}
function optClass(i) {
  if (!locked.value) return picked.value === i ? 'on' : ''
  if (i === cur.value.answer_index) return 'right'
  if (i === picked.value) return 'wrong'
  return 'dim'
}
function choose(i) {
  if (locked.value) return
  picked.value = i
  locked.value = true
  if (i === cur.value.answer_index) correct.value += 1
}
function next() {
  if (idx.value + 1 < list.value.length) {
    idx.value += 1
    picked.value = -1
    locked.value = false
  } else {
    finish()
  }
}
function finish() {
  const r = app.recordQuiz(chapterId.value, correct.value, list.value.length)
  earned.value = r.earned
  finished.value = true
}
function restart() {
  idx.value = 0
  picked.value = -1
  locked.value = false
  finished.value = false
  correct.value = 0
  earned.value = 0
}
function back() {
  uni.navigateBack({ delta: 1, fail: () => uni.redirectTo({ url: `/pages/learn/chapter?id=${chapterId.value}` }) })
}
</script>

<style lang="scss" scoped>
.qz {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.qz-prog {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.qz-prog-label {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.qz-prog-num {
  font-size: $fs-sm;
  color: $ink2;
}
.qz-card {
  padding: 32rpx;
  margin-top: 28rpx;
}
.qz-q-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.qz-pts {
  font-size: $fs-xs;
  color: $primary;
  background: $primarySoft;
  padding: 4rpx 16rpx;
  border-radius: $radius-pill;
  font-weight: 700;
}
.qz-q-no {
  font-size: $fs-xs;
  color: $ink3;
}
.qz-question {
  display: block;
  font-size: $fs-lg;
  font-weight: 700;
  color: $ink;
  line-height: 1.5;
  margin-bottom: 28rpx;
}
.qz-options {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}
.opt {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx;
  border: 2rpx solid $line;
  border-radius: $radius-md;
  background: $card;
}
.opt.on {
  border-color: $primary;
  background: $primarySoft;
}
.opt.right {
  border-color: $success;
  background: $successSoft;
}
.opt.wrong {
  border-color: $danger;
  background: $dangerSoft;
}
.opt.dim {
  opacity: 0.5;
}
.opt-letter {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: $line;
  color: $ink;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: $fs-sm;
  flex-shrink: 0;
}
.opt.right .opt-letter {
  background: $success;
  color: #fff;
}
.opt.wrong .opt-letter {
  background: $danger;
  color: #fff;
}
.opt-text {
  flex: 1;
  font-size: $fs-base;
  color: $ink;
  line-height: 1.5;
}
.opt-flag {
  font-size: 36rpx;
  color: $success;
  font-weight: 800;
}
.opt-flag.wrong {
  color: $danger;
}
.qz-explain {
  display: flex;
  gap: 16rpx;
  margin-top: 28rpx;
  padding: 24rpx;
  background: #f6f1ea;
  border-radius: $radius-md;
}
.ex-emoji {
  font-size: 40rpx;
}
.ex-body {
  flex: 1;
}
.ex-reply {
  display: block;
  font-size: $fs-base;
  font-weight: 700;
  color: $primary;
  margin-bottom: 8rpx;
}
.ex-text {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
}
.qz-next {
  margin-top: 28rpx;
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
  color: $ink;
  margin: 16rpx 0 12rpx;
}
.result-stat {
  display: block;
  font-size: $fs-md;
  color: $ink2;
  margin-bottom: 24rpx;
}
.result-earned {
  background: $primarySoft;
  border-radius: $radius-md;
  padding: 24rpx;
  margin-bottom: 24rpx;
}
.result-earned text {
  display: block;
  font-size: $fs-md;
  color: $primary;
  font-weight: 700;
}
.result-unlock {
  font-size: $fs-sm !important;
  color: $ink2 !important;
  font-weight: 400 !important;
  margin-top: 8rpx;
}
.result-hint {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin-bottom: 24rpx;
}
.result-actions {
  display: flex;
  gap: 20rpx;
  margin-top: 28rpx;
}
.result-btn {
  flex: 1;
}
</style>
