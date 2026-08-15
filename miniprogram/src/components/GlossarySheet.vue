<template>
  <view v-if="visible" class="gs-mask" @tap="close">
    <view class="gs-sheet" @tap.stop>
      <view class="gs-handle"></view>
      <view class="gs-head">
        <text class="gs-title">📚 查词</text>
        <text class="gs-sub">不懂的词，点一下就懂</text>
      </view>
      <view class="gs-search">
        <text class="gs-icon">🔍</text>
        <input
          class="gs-input"
          v-model="keyword"
          placeholder="搜词条，如「通胀」「复利」"
          confirm-type="search"
        />
        <text v-if="keyword" class="gs-clear" @tap="keyword = ''">✕</text>
      </view>

      <scroll-view scroll-y class="gs-list">
        <view v-if="!list.length" class="gs-empty">
          <text>没有找到「{{ keyword }}」相关词条</text>
        </view>
        <view
          v-for="(g, i) in list"
          :key="g.term"
          class="gs-item"
          :class="{ open: openTerm === g.term }"
          @tap="toggle(g.term)"
        >
          <view class="gs-item-head">
            <text class="gs-term">{{ g.term }}</text>
            <text v-if="g.aliases && g.aliases.length" class="gs-alias"
              >（{{ g.aliases.join('、') }}）</text
            >
            <text class="gs-arrow">{{ openTerm === g.term ? '▴' : '▾' }}</text>
          </view>
          <text class="gs-line">{{ g.one_line }}</text>
          <view v-if="openTerm === g.term" class="gs-detail">
            <view class="gs-ana" v-if="g.daily_analogy">
              <text class="gs-ana-label">🍊 生活类比</text>
              <text class="gs-ana-body">{{ g.daily_analogy }}</text>
            </view>
          </view>
        </view>
      </scroll-view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { searchGlossary } from '@/utils/content'

const props = defineProps({
  visible: { type: Boolean, default: false },
})
const emit = defineEmits(['close'])

const keyword = ref('')
const openTerm = ref('')

const list = computed(() => searchGlossary(keyword.value))

function toggle(term) {
  openTerm.value = openTerm.value === term ? '' : term
}

function close() {
  emit('close')
}
</script>

<style lang="scss" scoped>
.gs-mask {
  position: fixed;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  background: rgba(61, 43, 31, 0.4);
  z-index: 999;
  display: flex;
  align-items: flex-end;
}
.gs-sheet {
  width: 100%;
  max-height: 82vh;
  background: $cream;
  border-radius: $radius-lg $radius-lg 0 0;
  display: flex;
  flex-direction: column;
  padding-bottom: env(safe-area-inset-bottom);
}
.gs-handle {
  width: 72rpx;
  height: 8rpx;
  background: $ink3;
  border-radius: $radius-pill;
  margin: 16rpx auto 8rpx;
}
.gs-head {
  padding: 8rpx 32rpx 16rpx;
}
.gs-title {
  font-size: $fs-lg;
  font-weight: 800;
  color: $ink;
}
.gs-sub {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.gs-search {
  margin: 0 32rpx 16rpx;
  background: $card;
  border-radius: $radius-pill;
  height: 76rpx;
  display: flex;
  align-items: center;
  padding: 0 24rpx;
  gap: 12rpx;
  border: 1rpx solid $line;
}
.gs-icon {
  font-size: 30rpx;
}
.gs-input {
  flex: 1;
  font-size: $fs-base;
  color: $ink;
}
.gs-clear {
  color: $ink3;
  font-size: $fs-sm;
  padding: 0 8rpx;
}
.gs-list {
  flex: 1;
  padding: 0 32rpx 24rpx;
  max-height: 60vh;
}
.gs-empty {
  text-align: center;
  color: $ink2;
  font-size: $fs-sm;
  padding: 60rpx 0;
}
.gs-item {
  background: $card;
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
  margin-bottom: 16rpx;
  border: 1rpx solid $line;
}
.gs-item-head {
  display: flex;
  align-items: center;
  gap: 8rpx;
}
.gs-term {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.gs-alias {
  font-size: $fs-xs;
  color: $ink2;
  flex: 1;
}
.gs-arrow {
  font-size: $fs-sm;
  color: $ink3;
}
.gs-line {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin-top: 8rpx;
  line-height: 1.6;
}
.gs-detail {
  margin-top: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx dashed $line;
}
.gs-ana {
  background: $primarySoft;
  border-radius: $radius-md;
  padding: 16rpx 20rpx;
}
.gs-ana-label {
  font-size: $fs-xs;
  font-weight: 700;
  color: $primary;
}
.gs-ana-body {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  margin-top: 6rpx;
  line-height: 1.7;
}
</style>
