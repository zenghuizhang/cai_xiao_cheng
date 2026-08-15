<template>
  <view class="ph" :style="{ paddingTop: statusBarHeight + 'px' }">
    <view class="ph-bar">
      <view class="ph-left" @tap="onBack" v-if="showBack">
        <text class="ph-back">‹</text>
      </view>
      <view class="ph-left ph-placeholder" v-else></view>
      <text class="ph-title">{{ title }}</text>
      <view class="ph-right">
        <slot name="right"></slot>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  title: { type: String, default: '' },
  showBack: { type: Boolean, default: true },
})

const emit = defineEmits(['back'])

const statusBarHeight = ref(20)
try {
  const info = uni.getWindowInfo()
  statusBarHeight.value = info.statusBarHeight || 20
} catch (e) {
  // H5 兜底
  statusBarHeight.value = 20
}

function onBack() {
  emit('back')
  const pages = getCurrentPages()
  if (pages.length > 1) {
    uni.navigateBack()
  } else {
    uni.switchTab({ url: '/pages/home/home' })
  }
}
</script>

<style lang="scss" scoped>
.ph {
  background: $cream;
}
.ph-bar {
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24rpx;
  position: relative;
}
.ph-left {
  width: 64rpx;
  display: flex;
  align-items: center;
}
.ph-placeholder {
  visibility: hidden;
}
.ph-back {
  font-size: 56rpx;
  color: $ink;
  line-height: 1;
  margin-top: -8rpx;
}
.ph-title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.ph-right {
  min-width: 64rpx;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}
</style>
