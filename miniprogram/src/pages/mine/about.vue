<template>
  <view class="ab">
    <view class="ab-hero">
      <OrangeMascot :size="140" mood="smile" />
      <text class="ab-name">财小橙</text>
      <text class="ab-ver">v1.0.0 · 投资认知启蒙</text>
    </view>

    <view class="ab-card cx-card">
      <text class="ac-title">🍊 这是什么</text>
      <text class="ac-body">财小橙是一个纯教育产品，用大白话和「生活类比」帮你建立投资认知的地基——看懂通胀、分清工具、理解复利、识破骗局与情绪。不荐股、不预测、不承诺收益。</text>
    </view>

    <view class="ab-card cx-card">
      <text class="ac-title">🛡️ 重要免责声明</text>
      <view class="ac-warn">
        <text class="warn-text">{{ disclaimer }}</text>
      </view>
      <text class="ac-body" style="margin-top:16rpx">本应用所有数据、收益率、历史场景、虚拟资产均为假设性教学案例，不构成任何投资建议，不代表对未来收益的预测。投资有风险，决策需谨慎。</text>
    </view>

    <view class="ab-card cx-card">
      <text class="ac-title">🔒 数据与隐私</text>
      <text class="ac-body">· 学习进度默认存储在你的设备本地，未登录时可完全使用（游客模式）。</text>
      <text class="ac-body">· 登录后，进度会加密同步到云端，用于跨设备继续学习。我们仅存储学习记录与登录凭证，不收集其他敏感信息。</text>
      <text class="ac-body">· 你可随时在「我的」退出登录或重置进度。</text>
    </view>

    <view class="ab-card cx-card">
      <text class="ac-title">📦 内容来源</text>
      <text class="ac-body">知识卡片、测验、历史场景均为原创教学编写；书架为原创大白话摘要与导读，不复制原书原文，深入学习请购买或借阅正版图书。</text>
    </view>

    <view class="ab-foot">
      <text class="ab-foot-text">用认知，守护你的每一分钱 🍊</text>
    </view>
  </view>
</template>

<script setup>
import OrangeMascot from '@/components/OrangeMascot.vue'
import { getDisclaimer } from '@/utils/content'
const disclaimer = getDisclaimer()
</script>

<style lang="scss" scoped>
.ab {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.ab-hero {
  text-align: center;
  padding: 24rpx 0 32rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.ab-name {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
  margin-top: 16rpx;
}
.ab-ver {
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.ab-card {
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.ac-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
  margin-bottom: 16rpx;
}
.ac-body {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
  margin-bottom: 8rpx;
}
.ac-warn {
  background: $dangerSoft;
  border-left: 6rpx solid $danger;
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
}
.warn-text {
  font-size: $fs-sm;
  color: $ink;
  line-height: 1.7;
}
.ab-foot {
  text-align: center;
  padding: 24rpx 0 48rpx;
}
.ab-foot-text {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 600;
}
</style>
