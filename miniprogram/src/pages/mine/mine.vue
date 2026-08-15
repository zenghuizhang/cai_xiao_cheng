<template>
  <view class="me">
    <view class="me-head" :style="{ paddingTop: statusBar + 'px' }">
      <view class="me-head-row">
        <text class="me-head-title">我的</text>
      </view>
    </view>

    <scroll-view scroll-y class="me-body">
      <!-- 用户卡片 -->
      <view class="user-card cx-card" @tap="onUserTap">
        <view class="user-left">
          <image v-if="user.isLoggedIn && user.avatar" class="u-avatar" :src="user.avatar" mode="aspectFill" />
          <view v-else class="u-avatar u-default">🧑</view>
          <view class="u-info">
            <text class="u-name">{{ user.isLoggedIn ? user.nickname : '游客同学' }}</text>
            <text class="u-sub">{{ user.isLoggedIn ? (user.uid ? 'UID ' + user.uid : '已登录') : '点击登录，跨设备同步进度' }}</text>
            <text v-if="user.isLoggedIn && !user.cloudAvailable" class="u-warn">云端未连接，进度仅本地</text>
          </view>
        </view>
        <text class="u-arrow" v-if="!user.isLoggedIn">登录 ›</text>
        <view v-else-if="user.syncing" class="u-sync">同步中…</view>
      </view>

      <!-- 段位与积分 -->
      <view class="level-card cx-card">
        <LevelBadge :level="app.currentLevel" :rank-title="app.rankTitle" :size="96" />
        <view class="lv-stats">
          <view class="lv-stat">
            <text class="ls-num">{{ app.totalPoints }}</text>
            <text class="ls-label">认知积分</text>
          </view>
          <view class="lv-stat">
            <text class="ls-num">{{ app.cardsReadCount }}</text>
            <text class="ls-label">已读卡片</text>
          </view>
          <view class="lv-stat">
            <text class="ls-num">{{ app.chaptersPassedCount }}</text>
            <text class="ls-label">通关章节</text>
          </view>
        </view>
      </view>

      <!-- 数据概览 -->
      <view class="stat-grid">
        <view class="sg cx-card">
          <text class="sg-num">🔥 {{ app.streak }}</text>
          <text class="sg-label">连续天数</text>
        </view>
        <view class="sg cx-card">
          <text class="sg-num">🔄 {{ app.reviewCount }}</text>
          <text class="sg-label">复习队列</text>
        </view>
        <view class="sg cx-card">
          <text class="sg-num">✅ {{ app.masteredCount }}</text>
          <text class="sg-label">已掌握</text>
        </view>
        <view class="sg cx-card">
          <text class="sg-num">🍊 {{ formatWan(app.virtualAssets) }}</text>
          <text class="sg-label">认知本金</text>
        </view>
      </view>

      <!-- 风险画像 -->
      <view v-if="app.riskProfile" class="risk-card cx-card" @tap="goRisk">
        <view class="rc-left">
          <text class="rc-emoji">{{ riskMeta.emoji }}</text>
          <view>
            <text class="rc-title">{{ riskMeta.title }}</text>
            <text class="rc-desc">{{ riskMeta.desc }} · {{ app.riskAllocation(app.riskProfile) }}</text>
          </view>
        </view>
        <text class="rc-arrow">重测 ›</text>
      </view>

      <!-- 菜单 -->
      <view class="menu cx-card">
        <view class="menu-item" @tap="goRisk">
          <text class="mi-emoji">🧭</text>
          <text class="mi-label">风险承受力测评</text>
          <text class="mi-arrow">›</text>
        </view>
        <view class="menu-item" @tap="go('/pages/mine/crash')">
          <text class="mi-emoji">📉</text>
          <text class="mi-label">暴跌演练</text>
          <text class="mi-arrow">›</text>
        </view>
        <view class="menu-item" @tap="go('/pages/books/bookshelf')">
          <text class="mi-emoji">📚</text>
          <text class="mi-label">经典书架</text>
          <text class="mi-arrow">›</text>
        </view>
        <view class="menu-item" @tap="go('/pages/learn/review')">
          <text class="mi-emoji">🔄</text>
          <text class="mi-label">复习队列</text>
          <text class="mi-arrow">›</text>
        </view>
        <view class="menu-item" @tap="go('/pages/mine/about')">
          <text class="mi-emoji">ℹ️</text>
          <text class="mi-label">关于与免责</text>
          <text class="mi-arrow">›</text>
        </view>
      </view>

      <view v-if="user.isLoggedIn" class="cx-btn-outline me-logout" @tap="onLogout">退出登录</view>
      <view class="cx-btn-outline me-reset" @tap="onReset">重置学习进度</view>

      <view class="safe-bottom"></view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import LevelBadge from '@/components/LevelBadge.vue'
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

const riskMeta = computed(() => (app.riskProfile ? app.riskProfileMeta(app.riskProfile) : { emoji: '', title: '', desc: '' }))

function go(url) {
  uni.navigateTo({ url })
}
function goRisk() {
  uni.navigateTo({ url: '/pages/risk/risk-quiz' })
}
function onUserTap() {
  if (user.isLoggedIn) return
  uni.navigateTo({ url: '/pages/login/login' })
}
function onLogout() {
  uni.showModal({
    title: '退出登录',
    content: '退出后本地进度保留，但不再云端同步。',
    confirmText: '退出',
    confirmColor: '#e0533d',
    success: async (r) => {
      if (r.confirm) {
        await user.logout()
        uni.showToast({ title: '已退出', icon: 'none' })
      }
    },
  })
}
function onReset() {
  uni.showModal({
    title: '重置进度',
    content: '将清空所有学习记录（保留引导与风险画像），无法恢复。确定吗？',
    confirmText: '重置',
    confirmColor: '#e0533d',
    success: (r) => {
      if (r.confirm) {
        app.reset()
        uni.showToast({ title: '已重置', icon: 'success' })
      }
    },
  })
}
</script>

<style lang="scss" scoped>
.me {
  min-height: 100vh;
  background: $cream;
  display: flex;
  flex-direction: column;
}
.me-head {
  background: linear-gradient(180deg, #fff0e6 0%, $cream 100%);
  padding: 0 32rpx 16rpx;
}
.me-head-row {
  height: 72rpx;
  display: flex;
  align-items: center;
}
.me-head-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
}
.me-body {
  flex: 1;
  padding: 0 32rpx;
}
.user-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.user-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
  flex: 1;
  min-width: 0;
}
.u-avatar {
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  flex-shrink: 0;
}
.u-default {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48rpx;
  background: $primarySoft;
}
.u-info {
  flex: 1;
  min-width: 0;
}
.u-name {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
}
.u-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 6rpx;
}
.u-warn {
  display: block;
  font-size: 20rpx;
  color: $danger;
  margin-top: 4rpx;
}
.u-arrow {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 600;
  flex-shrink: 0;
}
.u-sync {
  font-size: $fs-xs;
  color: $ink2;
  flex-shrink: 0;
}
.level-card {
  display: flex;
  align-items: center;
  gap: 24rpx;
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.lv-stats {
  flex: 1;
  display: flex;
}
.lv-stat {
  flex: 1;
  text-align: center;
}
.ls-num {
  display: block;
  font-size: $fs-md;
  font-weight: 800;
  color: $primary;
}
.ls-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.stat-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
  margin-bottom: 24rpx;
}
.sg {
  width: calc((100% - 20rpx) / 2);
  padding: 24rpx;
  text-align: center;
}
.sg-num {
  display: block;
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.sg-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.risk-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.rc-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
  flex: 1;
  min-width: 0;
}
.rc-emoji {
  font-size: 48rpx;
}
.rc-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
}
.rc-desc {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.rc-arrow {
  font-size: $fs-sm;
  color: $primary;
  flex-shrink: 0;
}
.menu {
  padding: 8rpx 28rpx;
  margin-bottom: 32rpx;
}
.menu-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 28rpx 0;
  border-bottom: 1rpx solid $line;
}
.menu-item:last-child {
  border-bottom: none;
}
.mi-emoji {
  font-size: 40rpx;
}
.mi-label {
  flex: 1;
  font-size: $fs-base;
  color: $ink;
}
.mi-arrow {
  font-size: 40rpx;
  color: $ink3;
}
.me-logout {
  margin-bottom: 20rpx;
}
.me-reset {
  margin-bottom: 24rpx;
  color: $danger;
  border-color: $danger;
}
</style>
