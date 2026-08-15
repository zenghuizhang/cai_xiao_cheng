<template>
  <view class="ob">
    <swiper
      class="ob-swiper"
      :current="current"
      @change="onChange"
      :indicator-dots="false"
      circular
    >
      <!-- 1. 欢迎 -->
      <swiper-item>
        <view class="panel">
          <OrangeMascot :size="220" mood="smile" />
          <text class="p-title">你好，我是财小橙 🍊</text>
          <text class="p-body">陪你从零开始，建立投资认知的地基。</text>
          <text class="p-body">不荐股、不预测、不承诺收益——只讲大白话，让你看懂钱的世界。</text>
          <text class="p-dots">1 / 4</text>
        </view>
      </swiper-item>

      <!-- 2. 纯教育声明 -->
      <swiper-item>
        <view class="panel">
          <text class="p-emoji">🛡️</text>
          <text class="p-title">这是一个纯教育产品</text>
          <view class="p-list">
            <text class="p-li">✅ 教你建立认知框架，不教你炒股</text>
            <text class="p-li">✅ 所有收益率为假设性教学案例</text>
            <text class="p-li">✅ 没有开户、交易、荐股、加群入口</text>
            <text class="p-li">✅ 历史场景仅作推演，不代表未来</text>
          </view>
          <text class="p-dots">2 / 4</text>
        </view>
      </swiper-item>

      <!-- 3. 学习方式 -->
      <swiper-item>
        <view class="panel">
          <text class="p-emoji">🎴</text>
          <text class="p-title">像刷卡片一样学</text>
          <text class="p-body">每张卡一个概念，用「生活类比」讲透。</text>
          <view class="p-list">
            <text class="p-li">👉 右滑「懂了」拿积分</text>
            <text class="p-li">👈 左滑「没懂」自动进复习队列</text>
            <text class="p-li">🎯 通关测验，解锁下一章</text>
            <text class="p-li">🍊 成长树结果实，段位一路升级</text>
          </view>
          <text class="p-dots">3 / 4</text>
        </view>
      </swiper-item>

      <!-- 4. 风险提示 + 开始 -->
      <swiper-item>
        <view class="panel">
          <text class="p-emoji">⚠️</text>
          <text class="p-title">开始前，请记住</text>
          <view class="warn-box">
            <text class="warn-text">{{ disclaimer }}</text>
          </view>
          <text class="p-body" style="margin-top: 24rpx">本应用不构成任何投资建议。投资有风险，决策需谨慎。</text>
          <text class="p-dots">4 / 4</text>
        </view>
      </swiper-item>
    </swiper>

    <view class="ob-foot">
      <view class="dots">
        <view
          v-for="i in 4"
          :key="i"
          class="dot"
          :class="{ on: current === i - 1 }"
        ></view>
      </view>
      <view v-if="current < 3" class="skip" @tap="next">下一页 →</view>
      <view v-else class="cta" @tap="start">开始学习 🚀</view>
      <view class="skip-text" @tap="skip">跳过</view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import OrangeMascot from '@/components/OrangeMascot.vue'
import { useAppStore } from '@/store/app'
import { getDisclaimer } from '@/utils/content'

const app = useAppStore()
const current = ref(0)
const disclaimer = getDisclaimer()

function onChange(e) {
  current.value = e.detail.current
}

function next() {
  if (current.value < 3) current.value += 1
}

function skip() {
  start()
}

function start() {
  app.finishOnboarding()
  uni.switchTab({ url: '/pages/home/home' })
}
</script>

<style lang="scss" scoped>
.ob {
  min-height: 100vh;
  background: linear-gradient(180deg, #fff0e6 0%, $cream 40%);
  display: flex;
  flex-direction: column;
}
.ob-swiper {
  flex: 1;
  height: 100vh;
}
.panel {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 0 64rpx 200rpx;
  text-align: center;
}
.p-emoji {
  font-size: 140rpx;
  margin-bottom: 32rpx;
}
.p-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
  margin-bottom: 24rpx;
}
.p-body {
  font-size: $fs-base;
  color: $ink2;
  line-height: $lh-base;
  margin-bottom: 12rpx;
}
.p-list {
  margin-top: 16rpx;
  text-align: left;
  width: 100%;
}
.p-li {
  display: block;
  font-size: $fs-base;
  color: $ink;
  line-height: 2;
}
.p-dots {
  position: absolute;
  bottom: 220rpx;
  font-size: $fs-xs;
  color: $ink3;
}
.warn-box {
  background: $dangerSoft;
  border-left: 6rpx solid $danger;
  border-radius: $radius-md;
  padding: 24rpx;
  margin-top: 16rpx;
  width: 100%;
}
.warn-text {
  font-size: $fs-sm;
  color: $ink;
  line-height: 1.7;
}
.ob-foot {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 24rpx 64rpx calc(40rpx + env(safe-area-inset-bottom));
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20rpx;
}
.dots {
  display: flex;
  gap: 12rpx;
}
.dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background: $ink3;
  opacity: 0.4;
}
.dot.on {
  background: $primary;
  opacity: 1;
  width: 40rpx;
  border-radius: $radius-pill;
}
.cta {
  width: 100%;
  height: 96rpx;
  background: $primary;
  color: #fff;
  border-radius: $radius-pill;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $fs-md;
  font-weight: 700;
  box-shadow: 0 8rpx 24rpx rgba(229, 115, 42, 0.35);
}
.skip {
  font-size: $fs-base;
  color: $primary;
  font-weight: 600;
}
.skip-text {
  font-size: $fs-xs;
  color: $ink3;
}
</style>
