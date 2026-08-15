<template>
  <view class="learn">
    <view class="ly-head">
      <text class="ly-title">学习</text>
      <text class="ly-sub">四章打地基，从青铜到铂金 🍊</text>
    </view>

    <scroll-view scroll-y class="ly-body">
      <view
        v-for="ch in app.chapters"
        :key="ch.id"
        class="ch-card"
        :class="{ locked: !app.isChapterUnlocked(ch) }"
        @tap="enter(ch)"
      >
        <view class="ch-top">
          <text class="ch-emoji">{{ ch.cover_emoji }}</text>
          <view class="ch-info">
            <view class="ch-title-row">
              <text class="ch-title">{{ ch.title }}</text>
              <text class="ch-rank">{{ ch.rank_title }}</text>
            </view>
            <text class="ch-sub">{{ ch.subtitle }}</text>
          </view>
          <text v-if="!app.isChapterUnlocked(ch)" class="ch-lock">🔒</text>
          <text v-else-if="app.passedChapters.includes(ch.id)" class="ch-pass">✓</text>
          <text v-else class="ch-arrow">›</text>
        </view>
        <text class="ch-desc">{{ ch.description }}</text>
        <view class="ch-foot">
          <ProgressBar :read="stat(ch.id).read" :total="stat(ch.id).total" show-text />
          <text class="ch-min">约 {{ ch.estimated_minutes }} 分钟</text>
        </view>
      </view>

      <!-- 成长树 -->
      <view class="tree cx-card">
        <text class="tree-title">🌳 认知成长树</text>
        <view class="tree-fruits">
          <view
            v-for="f in fruits"
            :key="f.id"
            class="fruit"
            :class="{ on: app.unlockedFruits.includes(f.chapter_id) }"
          >
            <text class="fruit-emoji">{{ app.unlockedFruits.includes(f.chapter_id) ? f.emoji : '🔒' }}</text>
            <text class="fruit-label">{{ f.skill_label }}</text>
          </view>
        </view>
        <text class="tree-hint">通关每章测验，解锁一颗认知果实</text>
      </view>

      <view class="safe-bottom"></view>
    </scroll-view>

    <GlossaryFab />
  </view>
</template>

<script setup>
import ProgressBar from '@/components/ProgressBar.vue'
import GlossaryFab from '@/components/GlossaryFab.vue'
import { useAppStore } from '@/store/app'
import { getFruits } from '@/utils/content'

const app = useAppStore()
const fruits = getFruits()

function stat(chapterId) {
  return app.chapterReadStat(chapterId)
}

function enter(ch) {
  if (!app.isChapterUnlocked(ch)) {
    uni.showToast({ title: '通关上一章测验后解锁', icon: 'none' })
    return
  }
  uni.navigateTo({ url: `/pages/learn/chapter?id=${ch.id}` })
}
</script>

<style lang="scss" scoped>
.learn {
  min-height: 100vh;
  background: $cream;
  display: flex;
  flex-direction: column;
}
.ly-head {
  padding: 24rpx 32rpx 8rpx;
}
.ly-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
}
.ly-sub {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin-top: 4rpx;
}
.ly-body {
  flex: 1;
  padding: 16rpx 32rpx 0;
}
.ch-card {
  background: $card;
  border-radius: $radius-lg;
  border: 1rpx solid $line;
  box-shadow: $shadow-card;
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.ch-card.locked {
  opacity: 0.6;
}
.ch-top {
  display: flex;
  align-items: center;
  gap: 20rpx;
}
.ch-emoji {
  font-size: 64rpx;
}
.ch-info {
  flex: 1;
  min-width: 0;
}
.ch-title-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
}
.ch-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.ch-rank {
  font-size: $fs-xs;
  color: $primary;
  background: $primarySoft;
  padding: 2rpx 12rpx;
  border-radius: $radius-pill;
}
.ch-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 6rpx;
}
.ch-lock,
.ch-arrow {
  font-size: 40rpx;
  color: $ink3;
}
.ch-pass {
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: $success;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30rpx;
  font-weight: 700;
}
.ch-desc {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: 1.6;
  margin: 16rpx 0;
}
.ch-foot {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.ch-min {
  font-size: $fs-xs;
  color: $ink3;
  flex-shrink: 0;
}
.tree {
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.tree-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.tree-fruits {
  display: flex;
  justify-content: space-between;
  margin: 24rpx 0 16rpx;
}
.fruit {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  width: 24%;
}
.fruit-emoji {
  font-size: 56rpx;
}
.fruit:not(.on) .fruit-emoji {
  filter: grayscale(1);
  opacity: 0.4;
}
.fruit-label {
  font-size: 20rpx;
  color: $ink2;
  text-align: center;
  line-height: 1.3;
}
.fruit.on .fruit-label {
  color: $primary;
  font-weight: 600;
}
.tree-hint {
  font-size: $fs-xs;
  color: $ink3;
  text-align: center;
}
</style>
