<template>
  <view class="home">
    <!-- 顶部 -->
    <view class="head" :style="{ paddingTop: statusBar + 'px' }">
      <view class="head-row">
        <view class="brand">
          <OrangeMascot :size="64" mood="smile" />
          <view class="brand-text">
            <text class="brand-name">财小橙</text>
            <text class="brand-sub">投资认知启蒙</text>
          </view>
        </view>
        <view class="login-entry" @tap="goLogin">
          <image v-if="user.isLoggedIn && user.avatar" class="avatar" :src="user.avatar" mode="aspectFill" />
          <view v-else class="avatar avatar-default">🧑</view>
          <text class="login-name">{{ user.isLoggedIn ? user.nickname : '登录' }}</text>
        </view>
      </view>
    </view>

    <scroll-view scroll-y class="body" :style="{ paddingBottom: '180rpx' }">
      <!-- 成长概览 -->
      <view class="hero cx-card">
        <view class="hero-top">
          <LevelBadge :level="app.currentLevel" :rank-title="app.rankTitle" :size="108" />
          <view class="hero-stats">
            <view class="stat">
              <text class="stat-num">🍊 {{ formatWan(app.virtualAssets) }}</text>
              <text class="stat-label">认知本金（虚拟）</text>
            </view>
            <view class="stat">
              <text class="stat-num">{{ app.totalPoints }}</text>
              <text class="stat-label">认知积分</text>
            </view>
          </view>
        </view>
        <view class="hero-progress">
          <view class="hp-head">
            <text class="hp-label">学习进度</text>
            <text class="hp-num">{{ app.cardsReadCount }} / {{ app.totalCards }} 张</text>
          </view>
          <ProgressBar :read="app.cardsReadCount" :total="app.totalCards" />
        </view>
      </view>

      <!-- 继续学习 -->
      <view class="section-title">
        <text>继续学习</text>
        <text class="more" @tap="goTab('/pages/learn/learn')">全部章节 ›</text>
      </view>
      <view class="continue cx-card" @tap="goChapter">
        <text class="c-emoji">{{ curChapter.cover_emoji }}</text>
        <view class="c-info">
          <text class="c-title">{{ curChapter.title }}</text>
          <text class="c-sub">{{ curChapter.subtitle }}</text>
          <view class="c-prog">
            <ProgressBar :read="curStat.read" :total="curStat.total" show-text />
          </view>
        </view>
        <text class="c-arrow">›</text>
      </view>

      <!-- 每日挑战 -->
      <view class="daily-card" @tap="goPage('/pages/daily/daily')">
        <view class="dc-left">
          <text class="dc-emoji">🥣</text>
          <view>
            <text class="dc-title">每日 3 分钟</text>
            <text class="dc-sub">{{ app.isDailyDoneToday() ? `已坚持 ${app.streak} 天，明天见！` : '一道题，保持手感' }}</text>
          </view>
        </view>
        <text class="dc-streak" v-if="app.streak">🔥{{ app.streak }}</text>
        <text class="dc-go" v-else>去答题 ›</text>
      </view>

      <!-- 工具箱 -->
      <view class="section-title">
        <text>认知工具箱</text>
      </view>
      <view class="tools">
        <view
          v-for="t in tools"
          :key="t.label"
          class="tool"
          @tap="goPage(t.url)"
        >
          <text class="t-emoji">{{ t.emoji }}</text>
          <text class="t-label">{{ t.label }}</text>
        </view>
      </view>

      <Disclaimer variant="plain" title="温馨提示" icon="💡" :text="'本应用所有数据、收益率、历史场景均为假设性教学案例，不构成任何投资建议。'" />
      <view class="safe-bottom"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import OrangeMascot from '@/components/OrangeMascot.vue'
import LevelBadge from '@/components/LevelBadge.vue'
import ProgressBar from '@/components/ProgressBar.vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { useUserStore } from '@/store/user'
import { formatWan } from '@/utils/format'

const app = useAppStore()
const user = useUserStore()

const statusBar = (() => {
  try {
    return uni.getWindowInfo().statusBarHeight || 20
  } catch (e) {
    return 20
  }
})()

const curChapter = computed(() => app.currentChapter || {})
const curStat = computed(() => {
  if (!curChapter.value.id) return { read: 0, total: 0 }
  return app.chapterReadStat(curChapter.value.id)
})

const tools = [
  { emoji: '📈', label: '复利计算', url: '/pages/simulation/compound' },
  { emoji: '💸', label: '定投计算', url: '/pages/simulation/dca' },
  { emoji: '🫠', label: '通胀缩水', url: '/pages/simulation/inflation' },
  { emoji: '🎭', label: '模拟人生', url: '/pages/simulation/sim-life' },
  { emoji: '🧭', label: '风险测评', url: '/pages/risk/risk-quiz' },
  { emoji: '📉', label: '暴跌演练', url: '/pages/mine/crash' },
  { emoji: '📚', label: '经典书架', url: '/pages/books/bookshelf' },
  { emoji: '🔄', label: '复习队列', url: '/pages/learn/review' },
]

function goTab(url) {
  uni.switchTab({ url })
}
function goPage(url) {
  uni.navigateTo({ url })
}
function goLogin() {
  if (user.isLoggedIn) {
    uni.switchTab({ url: '/pages/mine/mine' })
  } else {
    uni.navigateTo({ url: '/pages/login/login' })
  }
}
function goChapter() {
  if (!curChapter.value.id) return
  uni.navigateTo({ url: `/pages/learn/chapter?id=${curChapter.value.id}` })
}
</script>

<style lang="scss" scoped>
.home {
  min-height: 100vh;
  background: $cream;
}
.head {
  background: linear-gradient(180deg, #fff0e6 0%, $cream 100%);
  padding: 0 32rpx 24rpx;
}
.head-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 88rpx;
}
.brand {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.brand-name {
  font-size: $fs-lg;
  font-weight: 800;
  color: $ink;
}
.brand-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
}
.login-entry {
  display: flex;
  align-items: center;
  gap: 10rpx;
  background: $card;
  padding: 8rpx 20rpx 8rpx 8rpx;
  border-radius: $radius-pill;
  border: 1rpx solid $line;
}
.avatar {
  width: 52rpx;
  height: 52rpx;
  border-radius: 50%;
}
.avatar-default {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  background: $primarySoft;
}
.login-name {
  font-size: $fs-sm;
  color: $ink;
}
.body {
  padding: 0 32rpx;
  height: calc(100vh - 200rpx);
}
.hero {
  padding: 32rpx;
  margin-bottom: 32rpx;
}
.hero-top {
  display: flex;
  align-items: center;
  gap: 24rpx;
  margin-bottom: 28rpx;
}
.hero-stats {
  flex: 1;
  display: flex;
  gap: 16rpx;
}
.stat {
  flex: 1;
}
.stat-num {
  display: block;
  font-size: $fs-md;
  font-weight: 800;
  color: $primary;
}
.stat-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.hero-progress {
  padding-top: 20rpx;
  border-top: 1rpx solid $line;
}
.hp-head {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12rpx;
}
.hp-label {
  font-size: $fs-sm;
  color: $ink2;
}
.hp-num {
  font-size: $fs-sm;
  color: $ink;
  font-weight: 600;
}
.section-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  margin: 8rpx 0 20rpx;
}
.more {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 400;
}
.continue {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.c-emoji {
  font-size: 64rpx;
}
.c-info {
  flex: 1;
  min-width: 0;
}
.c-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.c-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin: 6rpx 0 12rpx;
}
.c-prog {
  width: 100%;
}
.c-arrow {
  font-size: 44rpx;
  color: $ink3;
}
.daily-card {
  background: linear-gradient(135deg, #ffb37a, #ff8c42);
  border-radius: $radius-lg;
  padding: 28rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 32rpx;
}
.dc-left {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.dc-emoji {
  font-size: 48rpx;
}
.dc-title {
  color: #fff;
  font-size: $fs-md;
  font-weight: 700;
}
.dc-sub {
  display: block;
  color: rgba(255, 255, 255, 0.85);
  font-size: $fs-xs;
  margin-top: 4rpx;
}
.dc-streak,
.dc-go {
  color: #fff;
  font-size: $fs-sm;
  font-weight: 700;
  background: rgba(255, 255, 255, 0.2);
  padding: 8rpx 20rpx;
  border-radius: $radius-pill;
}
.tools {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
  margin-bottom: 32rpx;
}
.tool {
  width: calc((100% - 60rpx) / 4);
  background: $card;
  border-radius: $radius-md;
  border: 1rpx solid $line;
  padding: 24rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10rpx;
}
.t-emoji {
  font-size: 44rpx;
}
.t-label {
  font-size: $fs-xs;
  color: $ink;
}
</style>
