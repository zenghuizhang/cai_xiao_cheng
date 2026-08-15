<template>
  <view class="dy">
    <view class="dy-head">
      <text class="dy-date">{{ todayLabel }}</text>
      <text v-if="app.streak" class="dy-streak">🔥 已坚持 {{ app.streak }} 天</text>
    </view>

    <view class="dy-card cx-card" v-if="q">
      <OrangeMascot :size="120" mood="think" />
      <text class="dy-q">{{ q.question }}</text>
      <text class="dy-hint">判断下面这句话，对还是错？</text>

      <view v-if="!answered && !doneToday" class="dy-choices">
        <view class="dy-btn dy-wrong" @tap="answer(false)">
          <text>❌ 错</text>
        </view>
        <view class="dy-btn dy-right" @tap="answer(true)">
          <text>✅ 对</text>
        </view>
      </view>

      <view v-if="answered || doneToday" class="dy-result">
        <text class="dy-verdict" :class="{ right: isCorrect }">
          {{ doneToday && !justAnswered ? '今日已完成 ✓' : (isCorrect ? '答对啦 🎉' : '答错了 💡') }}
        </text>
        <view class="dy-explain">
          <text class="ex-label">解析</text>
          <text class="ex-body">{{ q.explanation }}</text>
        </view>
        <text class="dy-earned" v-if="justAnswered">认知积分 +{{ earned }} 🍊</text>
        <text class="dy-come" v-if="doneToday">明天再来，保持手感～</text>
      </view>
    </view>

    <view v-else class="dy-empty">
      <OrangeMascot :size="160" mood="open" />
      <text class="dy-empty-t">今日题目还没准备好</text>
      <text class="dy-empty-s">稍后再来看看吧</text>
    </view>

    <Disclaimer variant="plain" title="提示" icon="💡" text="每日一题用于巩固认知，不构成任何投资建议。" />
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import OrangeMascot from '@/components/OrangeMascot.vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { getDailyByDate } from '@/utils/content'

const app = useAppStore()

function ymd(d) {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}
const today = ymd(new Date())
const todayLabel = `${today.slice(5).replace('-', '月')}日 · 每日3分钟`
const q = getDailyByDate(today)

const doneToday = computed(() => app.isDailyDoneToday())
const answered = ref(false)
const justAnswered = ref(false)
const picked = ref(null)
const earned = ref(0)

const isCorrect = computed(() => picked.value === q.answer)

function answer(choice) {
  picked.value = choice
  const correct = choice === q.answer ? 1 : 0
  const r = app.recordDaily(correct, 1)
  earned.value = r.earned
  answered.value = true
  justAnswered.value = true
}
</script>

<style lang="scss" scoped>
.dy {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.dy-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}
.dy-date {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.dy-streak {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 700;
  background: $primarySoft;
  padding: 6rpx 20rpx;
  border-radius: $radius-pill;
}
.dy-card {
  padding: 48rpx 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}
.dy-q {
  display: block;
  font-size: $fs-lg;
  font-weight: 700;
  color: $ink;
  line-height: 1.6;
  margin: 24rpx 0 8rpx;
}
.dy-hint {
  font-size: $fs-sm;
  color: $ink2;
  margin-bottom: 32rpx;
}
.dy-choices {
  display: flex;
  gap: 24rpx;
  width: 100%;
}
.dy-btn {
  flex: 1;
  height: 112rpx;
  border-radius: $radius-pill;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $fs-md;
  font-weight: 700;
}
.dy-right {
  background: $primary;
  color: #fff;
}
.dy-wrong {
  background: $card;
  border: 2rpx solid $line;
  color: $ink;
}
.dy-result {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.dy-verdict {
  font-size: $fs-lg;
  font-weight: 800;
  color: $danger;
  margin-bottom: 24rpx;
}
.dy-verdict.right {
  color: $success;
}
.dy-explain {
  width: 100%;
  background: #f6f1ea;
  border-radius: $radius-md;
  padding: 24rpx;
  text-align: left;
}
.ex-label {
  display: block;
  font-size: $fs-xs;
  font-weight: 700;
  color: $ink2;
  margin-bottom: 8rpx;
}
.ex-body {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
}
.dy-earned {
  font-size: $fs-md;
  color: $primary;
  font-weight: 700;
  margin-top: 24rpx;
}
.dy-come {
  font-size: $fs-sm;
  color: $ink3;
  margin-top: 12rpx;
}
.dy-empty {
  margin-top: 120rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.dy-empty-t {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  margin-top: 24rpx;
}
.dy-empty-s {
  font-size: $fs-sm;
  color: $ink2;
  margin-top: 8rpx;
}
</style>
