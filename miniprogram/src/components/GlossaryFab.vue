<template>
  <view class="fab-wrap">
    <view class="fab" @tap="open">
      <text class="fab-icon">📚</text>
      <text class="fab-text">查词</text>
    </view>
    <GlossarySheet :visible="visible" @close="close" />
  </view>
</template>

<script setup>
import { ref } from 'vue'
import GlossarySheet from './GlossarySheet.vue'

const visible = ref(false)

function open() {
  visible.value = true
}
function close() {
  visible.value = false
}
</script>

<style lang="scss" scoped>
.fab-wrap {
  position: fixed;
  right: 32rpx;
  bottom: calc(140rpx + env(safe-area-inset-bottom));
  z-index: 50;
}
.fab {
  width: 104rpx;
  height: 104rpx;
  border-radius: 50%;
  background: $primary;
  box-shadow: 0 8rpx 24rpx rgba(229, 115, 42, 0.4);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.fab-icon {
  font-size: 32rpx;
  line-height: 1;
}
.fab-text {
  font-size: 20rpx;
  color: #fff;
  margin-top: 2rpx;
  line-height: 1;
}
</style>
