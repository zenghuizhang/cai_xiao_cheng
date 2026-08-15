<template>
  <view class="ch" v-if="chapter">
    <view class="ch-hero" :style="{ background: heroBg }">
      <text class="ch-emoji">{{ chapter.cover_emoji }}</text>
      <text class="ch-title">{{ chapter.title }}</text>
      <text class="ch-sub">{{ chapter.subtitle }}</text>
      <view class="ch-meta">
        <text class="ch-rank">{{ chapter.rank_title }}</text>
        <text class="ch-min">约 {{ chapter.estimated_minutes }} 分钟</text>
      </view>
    </view>

    <view class="ch-desc cx-card">
      <text>{{ chapter.description }}</text>
      <view class="ch-prog">
        <text class="cp-label">本章进度</text>
        <ProgressBar :read="stat.read" :total="stat.total" show-text />
      </view>
    </view>

    <!-- 知识卡片 -->
    <view class="entry cx-card" @tap="goSwipe">
      <view class="entry-left">
        <text class="entry-emoji">🎴</text>
        <view>
          <text class="entry-title">知识卡片</text>
          <text class="entry-sub">{{ stat.read }}/{{ stat.total }} 张已读 · 右滑懂了，左滑待复习</text>
        </view>
      </view>
      <text class="entry-arrow">›</text>
    </view>

    <!-- 闯关测验 -->
    <view class="entry cx-card" @tap="goQuiz">
      <view class="entry-left">
        <text class="entry-emoji">🎯</text>
        <view>
          <text class="entry-title">闯关测验</text>
          <text class="entry-sub">{{ quizPassed ? '已通关 ✓' : '答对 80% 即通关解锁下一章' }}</text>
        </view>
      </view>
      <text class="entry-arrow">›</text>
    </view>

    <!-- 历史模拟 -->
    <view v-if="sims.length" class="sim-section">
      <text class="sim-title">🎭 历史场景模拟</text>
      <view
        v-for="s in sims"
        :key="s.id"
        class="entry cx-card"
        @tap="goSim(s.id)"
      >
        <view class="entry-left">
          <text class="entry-emoji">🎞️</text>
          <view>
            <text class="entry-title">{{ s.title }}</text>
            <text class="entry-sub">{{ s.background }}</text>
          </view>
        </view>
        <text class="entry-arrow">›</text>
      </view>
    </view>

    <Disclaimer variant="plain" title="教学说明" icon="💡" text="历史场景为假设性推演，仅用于理解概念，不代表真实收益或对未来预测。" />
    <view class="safe-bottom"></view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import ProgressBar from '@/components/ProgressBar.vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { getChapter, getCardsByChapter, getQuizzesByChapter, getSimulationsByChapter } from '@/utils/content'

const app = useAppStore()
const chapterId = ref('')
const chapter = ref(null)

onLoad((options) => {
  chapterId.value = options.id
  chapter.value = getChapter(options.id)
})

const stat = computed(() => app.chapterReadStat(chapterId.value))
const sims = computed(() => (chapterId.value ? getSimulationsByChapter(chapterId.value) : []))
const quizPassed = computed(() => app.passedChapters.includes(chapterId.value))

const heroBg = computed(() => {
  if (!chapter.value) return ''
  return `linear-gradient(135deg, ${chapter.value.theme_color}dd, ${chapter.value.theme_color}99)`
})

function goSwipe() {
  uni.navigateTo({ url: `/pages/learn/swipe?chapter=${chapterId.value}` })
}
function goQuiz() {
  uni.navigateTo({ url: `/pages/learn/quiz?chapter=${chapterId.value}` })
}
function goSim(simId) {
  uni.navigateTo({ url: `/pages/simulation/sim-life?id=${simId}` })
}
</script>

<style lang="scss" scoped>
.ch {
  min-height: 100vh;
  background: $cream;
  padding-bottom: 40rpx;
}
.ch-hero {
  padding: 40rpx 32rpx 48rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}
.ch-emoji {
  font-size: 96rpx;
  margin-bottom: 16rpx;
}
.ch-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: #fff;
}
.ch-sub {
  font-size: $fs-sm;
  color: rgba(255, 255, 255, 0.9);
  margin-top: 8rpx;
}
.ch-meta {
  display: flex;
  gap: 16rpx;
  margin-top: 20rpx;
}
.ch-rank,
.ch-min {
  font-size: $fs-xs;
  color: #fff;
  background: rgba(255, 255, 255, 0.25);
  padding: 6rpx 20rpx;
  border-radius: $radius-pill;
}
.ch-desc {
  margin: -24rpx 32rpx 24rpx;
  padding: 28rpx;
  position: relative;
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
}
.ch-prog {
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid $line;
}
.cp-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-bottom: 12rpx;
}
.entry {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx;
  margin: 0 32rpx 20rpx;
}
.entry-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
  flex: 1;
  min-width: 0;
}
.entry-emoji {
  font-size: 48rpx;
}
.entry-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.entry-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 6rpx;
  line-height: 1.5;
}
.entry-arrow {
  font-size: 44rpx;
  color: $ink3;
}
.sim-section {
  margin: 16rpx 32rpx 24rpx;
}
.sim-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
  margin-bottom: 16rpx;
}
.sim-section .entry {
  margin: 0 0 20rpx;
}
</style>
