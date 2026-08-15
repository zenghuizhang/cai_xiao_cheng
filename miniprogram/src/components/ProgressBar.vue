<template>
  <view class="pb-wrap">
    <view class="pb-track">
      <view class="pb-fill" :style="fillStyle"></view>
    </view>
    <text v-if="showText" class="pb-text">{{ read }}/{{ total }}</text>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  read: { type: Number, default: 0 },
  total: { type: Number, default: 0 },
  color: { type: String, default: '' },
  showText: { type: Boolean, default: false },
  height: { type: String, default: '14rpx' },
})

const percent = computed(() => {
  if (!props.total) return 0
  return Math.min(100, Math.round((props.read / props.total) * 100))
})

const fillStyle = computed(() => ({
  width: percent.value + '%',
  height: props.height,
  background: props.color || 'linear-gradient(90deg,#ffb37a,#ff8c42)',
}))
</script>

<style lang="scss" scoped>
.pb-wrap {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.pb-track {
  flex: 1;
  height: 14rpx;
  background: $line;
  border-radius: $radius-pill;
  overflow: hidden;
}
.pb-fill {
  border-radius: $radius-pill;
  transition: width 0.4s ease;
}
.pb-text {
  font-size: $fs-xs;
  color: $ink2;
  flex-shrink: 0;
}
</style>
