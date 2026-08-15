<template>
  <view class="sim">
    <view class="sim-head">
      <text class="sim-title">认知工具箱</text>
      <text class="sim-sub">用假设场景算一算、演一演，建立直觉</text>
    </view>

    <!-- 历史场景进度 -->
    <view class="sim-prog cx-card" @tap="goSimLife">
      <view class="sp-left">
        <text class="sp-emoji">🎭</text>
        <view>
          <text class="sp-title">历史场景模拟</text>
          <text class="sp-sub">已体验 {{ simDone }} / {{ simTotal }} 个场景</text>
        </view>
      </view>
      <text class="sp-arrow">›</text>
    </view>

    <text class="grp-title">🧮 计算器</text>
    <view class="grid">
      <view class="grid-item" @tap="go('/pages/simulation/compound')">
        <text class="gi-emoji">📈</text>
        <text class="gi-label">复利计算</text>
        <text class="gi-desc">一次性本金的成长</text>
      </view>
      <view class="grid-item" @tap="go('/pages/simulation/dca')">
        <text class="gi-emoji">💸</text>
        <text class="gi-label">定投计算</text>
        <text class="gi-desc">每月坚持的复利</text>
      </view>
      <view class="grid-item" @tap="go('/pages/simulation/inflation')">
        <text class="gi-emoji">🫠</text>
        <text class="gi-label">通胀缩水</text>
        <text class="gi-desc">钱放着的隐形流失</text>
      </view>
      <view class="grid-item" @tap="goSimLife">
        <text class="gi-emoji">🎞️</text>
        <text class="gi-label">模拟人生</text>
        <text class="gi-desc">回到历史做选择</text>
      </view>
    </view>

    <text class="grp-title">🧭 自我认知</text>
    <view class="grid">
      <view class="grid-item" @tap="go('/pages/risk/risk-quiz')">
        <text class="gi-emoji">🧭</text>
        <text class="gi-label">风险测评</text>
        <text class="gi-desc">测测你的风险画像</text>
      </view>
      <view class="grid-item" @tap="go('/pages/mine/crash')">
        <text class="gi-emoji">📉</text>
        <text class="gi-label">暴跌演练</text>
        <text class="gi-desc">提前经历一次大跌</text>
      </view>
    </view>

    <Disclaimer variant="plain" title="温馨提示" icon="💡" text="所有工具均为假设性教学推演，不构成任何投资建议。投资有风险，决策需谨慎。" />
    <view class="safe-bottom"></view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { useAppStore } from '@/store/app'
import { getSimulations } from '@/utils/content'

const app = useAppStore()
const simTotal = getSimulations().length
const simDone = computed(() => Object.keys(app.progress.sim_records || {}).length)

function go(url) {
  uni.navigateTo({ url })
}
function goSimLife() {
  uni.navigateTo({ url: '/pages/simulation/sim-life' })
}
</script>

<style lang="scss" scoped>
.sim {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.sim-head {
  margin-bottom: 24rpx;
}
.sim-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
}
.sim-sub {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin-top: 4rpx;
}
.sim-prog {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28rpx;
  margin-bottom: 32rpx;
  background: linear-gradient(135deg, #fff0e6, $card);
}
.sp-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
}
.sp-emoji {
  font-size: 56rpx;
}
.sp-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.sp-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.sp-arrow {
  font-size: 44rpx;
  color: $ink3;
}
.grp-title {
  display: block;
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  margin: 8rpx 0 20rpx;
}
.grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
  margin-bottom: 32rpx;
}
.grid-item {
  width: calc((100% - 20rpx) / 2);
  background: $card;
  border-radius: $radius-lg;
  border: 1rpx solid $line;
  box-shadow: $shadow-card;
  padding: 32rpx 28rpx;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}
.gi-emoji {
  font-size: 52rpx;
}
.gi-label {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.gi-desc {
  font-size: $fs-xs;
  color: $ink2;
}
</style>
