<template>
  <view class="swipe">
    <!-- 背后动作提示 -->
    <view class="hint hint-left" :style="{ opacity: leftOpacity }">
      <text class="hint-emoji">🤔</text>
      <text class="hint-text">没懂·待复习</text>
    </view>
    <view class="hint hint-right" :style="{ opacity: rightOpacity }">
      <text class="hint-emoji">✅</text>
      <text class="hint-text">懂了</text>
    </view>

    <!-- 卡片本体 -->
    <view
      class="card"
      :style="cardStyle"
      @touchstart="onStart"
      @touchmove="onMove"
      @touchend="onEnd"
      @touchcancel="onEnd"
    >
      <view class="card-head">
        <text class="tag">第{{ card.chapter }}章</text>
        <view class="dots">
          <view
            v-for="d in 3"
            :key="d"
            class="dot"
            :class="{ on: d <= card.difficulty }"
          ></view>
        </view>
        <text class="pts">+{{ card.points }}</text>
      </view>

      <text class="title">{{ card.title }}</text>

      <view class="block analogy">
        <text class="block-label">🍊 生活类比</text>
        <text class="block-body">{{ card.daily_analogy }}</text>
      </view>

      <view class="block knowledge">
        <text class="block-label">📖 核心知识</text>
        <text class="block-body">{{ card.core_knowledge }}</text>
      </view>

      <view class="terms" v-if="card.glossary_terms && card.glossary_terms.length">
        <text
          v-for="t in card.glossary_terms"
          :key="t"
          class="term-chip"
          @tap.stop="emit('glossary', t)"
        >📚 {{ t }}</text>
      </view>

      <view class="foot-hint">
        <text>👈 左滑「没懂」</text>
        <text>「懂了」右滑 👉</text>
      </view>
    </view>

    <!-- 备用按钮（手势不直观时的兜底） -->
    <view class="actions">
      <view class="act act-review" @tap="emit('review', card.id)">
        <text>🤔 没懂，待复习</text>
      </view>
      <view class="act act-got" @tap="emit('got', card.id)">
        <text>✅ 懂了</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  card: { type: Object, required: true },
})
const emit = defineEmits(['got', 'review', 'glossary'])

const THRESHOLD = 60 // px，超过即触发

const offset = ref(0)
const startX = ref(0)
const startY = ref(0)
const dragging = ref(false)
const horizontal = ref(false)

const cardStyle = computed(() => ({
  transform: `translateX(${offset.value}px) rotate(${offset.value * 0.04}deg)`,
  transition: dragging.value ? 'none' : 'transform 0.3s ease',
}))

const leftOpacity = computed(() =>
  Math.min(1, -offset.value / THRESHOLD)
)
const rightOpacity = computed(() =>
  Math.min(1, offset.value / THRESHOLD)
)

function onStart(e) {
  const t = e.touches[0]
  startX.value = t.clientX
  startY.value = t.clientY
  dragging.value = true
  horizontal.value = false
}

function onMove(e) {
  if (!dragging.value) return
  const t = e.touches[0]
  const dx = t.clientX - startX.value
  const dy = t.clientY - startY.value
  if (!horizontal.value) {
    // 判定主方向，竖向则让页面滚动
    if (Math.abs(dy) > Math.abs(dx) && Math.abs(dy) > 8) {
      dragging.value = false
      return
    }
    if (Math.abs(dx) > 8) horizontal.value = true
  }
  if (horizontal.value) {
    offset.value = dx
  }
}

function onEnd() {
  if (!dragging.value && !horizontal.value) {
    offset.value = 0
    return
  }
  dragging.value = false
  if (offset.value > THRESHOLD) {
    // 右滑 → 懂了
    offset.value = 500
    setTimeout(() => emit('got', props.card.id), 120)
  } else if (offset.value < -THRESHOLD) {
    // 左滑 → 没懂
    offset.value = -500
    setTimeout(() => emit('review', props.card.id), 120)
  } else {
    offset.value = 0
  }
}
</script>

<style lang="scss" scoped>
.swipe {
  position: relative;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.card {
  position: relative;
  width: 100%;
  background: $card;
  border-radius: $radius-lg;
  border: 1rpx solid $line;
  box-shadow: $shadow-card;
  padding: 36rpx 32rpx 28rpx;
  z-index: 2;
  will-change: transform;
}
.card-head {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 20rpx;
}
.tag {
  font-size: $fs-xs;
  color: $primary;
  background: $primarySoft;
  padding: 4rpx 16rpx;
  border-radius: $radius-pill;
  font-weight: 600;
}
.dots {
  display: flex;
  gap: 6rpx;
  flex: 1;
}
.dot {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: $line;
}
.dot.on {
  background: $primary;
}
.pts {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 700;
}
.title {
  display: block;
  font-size: $fs-lg;
  font-weight: 800;
  color: $ink;
  line-height: 1.4;
  margin-bottom: 24rpx;
}
.block {
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
  margin-bottom: 20rpx;
}
.analogy {
  background: $primarySoft;
}
.knowledge {
  background: #f6f1ea;
}
.block-label {
  display: block;
  font-size: $fs-xs;
  font-weight: 700;
  color: $ink2;
  margin-bottom: 8rpx;
}
.block-body {
  display: block;
  font-size: $fs-base;
  color: $ink;
  line-height: $lh-base;
}
.terms {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-bottom: 24rpx;
}
.term-chip {
  font-size: $fs-xs;
  color: $ink;
  background: $card;
  border: 1rpx solid $line;
  padding: 6rpx 18rpx;
  border-radius: $radius-pill;
}
.foot-hint {
  display: flex;
  justify-content: space-between;
  font-size: $fs-xs;
  color: $ink3;
  padding-top: 8rpx;
  border-top: 1rpx dashed $line;
}
.actions {
  display: flex;
  gap: 20rpx;
  width: 100%;
  margin-top: 28rpx;
}
.act {
  flex: 1;
  height: 88rpx;
  border-radius: $radius-pill;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $fs-base;
  font-weight: 700;
}
.act-review {
  background: $card;
  border: 2rpx solid $line;
  color: $ink;
}
.act-got {
  background: $primary;
  color: #fff;
}
/* 背后提示 */
.hint {
  position: absolute;
  top: 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  z-index: 1;
}
.hint-left {
  left: 60rpx;
}
.hint-right {
  right: 60rpx;
}
.hint-emoji {
  font-size: 56rpx;
}
.hint-text {
  font-size: $fs-xs;
  color: $ink2;
  font-weight: 600;
}
</style>
