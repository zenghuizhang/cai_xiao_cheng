<template>
  <view class="disc" :class="['disc-' + variant]">
    <view class="disc-head">
      <text class="disc-icon">{{ icon }}</text>
      <text class="disc-title">{{ title }}</text>
    </view>
    <text class="disc-body">{{ body }}</text>
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { getDisclaimer } from '@/utils/content'

const props = defineProps({
  variant: { type: String, default: 'warn' }, // warn | point | plain
  title: { type: String, default: '风险提示' },
  icon: { type: String, default: '⚠️' },
  text: { type: String, default: '' },
  useDefault: { type: Boolean, default: false },
})

const body = computed(() =>
  props.useDefault ? getDisclaimer() : props.text
)
</script>

<style lang="scss" scoped>
.disc {
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
  font-size: $fs-sm;
  line-height: 1.7;
}
.disc-warn {
  background: $dangerSoft;
  border-left: 6rpx solid $danger;
}
.disc-point {
  background: $successSoft;
  border-left: 6rpx solid $success;
}
.disc-plain {
  background: $primarySoft;
  border-left: 6rpx solid $primary;
}
.disc-head {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 8rpx;
}
.disc-icon {
  font-size: 30rpx;
}
.disc-title {
  font-size: $fs-sm;
  font-weight: 700;
  color: $ink;
}
.disc-body {
  display: block;
  color: $ink;
}
</style>
