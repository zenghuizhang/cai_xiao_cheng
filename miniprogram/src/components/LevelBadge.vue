<template>
  <view class="lb" :style="{ '--c': color }">
    <view class="lb-ring" :style="ringStyle">
      <text class="lb-num">{{ level }}</text>
    </view>
    <view v-if="rankTitle" class="lb-meta">
      <text class="lb-title">{{ rankTitle }}</text>
      <text v-if="subtitle" class="lb-sub">{{ subtitle }}</text>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const LEVEL_COLORS = {
  1: '#cd7f32', // 青铜
  2: '#9aa7b0', // 白银
  3: '#e5a83b', // 黄金
  4: '#7b6bd6', // 铂金
}

const props = defineProps({
  level: { type: [Number, String], default: 1 },
  rankTitle: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  size: { type: [Number, String], default: 96 },
})

const color = computed(() => LEVEL_COLORS[Number(props.level)] || LEVEL_COLORS[1])
const ringStyle = computed(() => ({
  width: props.size + 'rpx',
  height: props.size + 'rpx',
  borderColor: color.value,
}))
</script>

<style lang="scss" scoped>
.lb {
  display: flex;
  align-items: center;
  gap: 20rpx;
}
.lb-ring {
  border-radius: 50%;
  border: 4rpx solid var(--c);
  background: $card;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
}
.lb-num {
  font-size: 44rpx;
  font-weight: 800;
  color: var(--c);
}
.lb-meta {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}
.lb-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.lb-sub {
  font-size: $fs-xs;
  color: $ink2;
}
</style>
