<template>
  <view class="bd" v-if="book">
    <view class="bd-hero">
      <view class="bd-cover">
        <text class="bd-emoji">{{ book.cover_emoji }}</text>
      </view>
      <text class="bd-title">{{ book.title }}</text>
      <text class="bd-author">{{ book.author }}</text>
      <view class="bd-tags">
        <text v-for="t in book.tags" :key="t" class="bd-tag">{{ t }}</text>
      </view>
    </view>

    <view class="bd-one cx-card">
      <text class="bd-one-text">“{{ book.one_line }}”</text>
    </view>

    <view class="bd-section cx-card">
      <text class="sec-title">📖 为什么读它</text>
      <text class="sec-body">{{ book.why_read }}</text>
    </view>

    <view class="bd-section cx-card">
      <text class="sec-title">💡 核心思想</text>
      <view v-for="(c, i) in book.core_ideas" :key="i" class="idea">
        <text class="idea-no">{{ i + 1 }}</text>
        <view class="idea-body">
          <text class="idea-title">{{ c.idea }}</text>
          <text class="idea-explain">{{ c.explain }}</text>
        </view>
      </view>
    </view>

    <view class="bd-section cx-card">
      <text class="sec-title">✅ 一句话带走</text>
      <text v-for="(t, i) in book.takeaways" :key="i" class="take">· {{ t }}</text>
    </view>

    <view class="bd-section cx-card">
      <text class="sec-title">🎯 适合谁读</text>
      <text class="sec-body">{{ book.for_whom }}</text>
    </view>

    <view class="bd-section cx-card">
      <text class="sec-title">🗺️ 阅读路径</text>
      <text class="sec-body">{{ book.read_path }}</text>
    </view>

    <view v-if="related.length" class="bd-section cx-card">
      <text class="sec-title">🔗 关联章节</text>
      <view class="rel-list">
        <view
          v-for="ch in related"
          :key="ch.id"
          class="rel-chip"
          @tap="goChapter(ch.id)"
        >
          <text>{{ ch.cover_emoji }} {{ ch.title }}</text>
        </view>
      </view>
    </view>

    <Disclaimer variant="plain" title="说明" icon="📚" :text="note" />
    <view class="safe-bottom"></view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import Disclaimer from '@/components/Disclaimer.vue'
import { getBook, getBooksNote, getChapter } from '@/utils/content'

const id = ref('')
const book = computed(() => (id.value ? getBook(id.value) : null))
const note = getBooksNote()
const related = computed(() => {
  if (!book.value) return []
  return (book.value.related_chapters || []).map((cid) => getChapter(cid)).filter(Boolean)
})

onLoad((options) => {
  id.value = options.id
})

function goChapter(cid) {
  uni.navigateTo({ url: `/pages/learn/chapter?id=${cid}` })
}
</script>

<style lang="scss" scoped>
.bd {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.bd-hero {
  text-align: center;
  padding: 24rpx 0 32rpx;
}
.bd-cover {
  width: 160rpx;
  height: 200rpx;
  background: $primarySoft;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20rpx;
}
.bd-emoji {
  font-size: 80rpx;
}
.bd-title {
  display: block;
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
}
.bd-author {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin-top: 8rpx;
}
.bd-tags {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 10rpx;
  margin-top: 16rpx;
}
.bd-tag {
  font-size: 20rpx;
  color: $primary;
  background: $primarySoft;
  padding: 4rpx 16rpx;
  border-radius: $radius-pill;
}
.bd-one {
  padding: 28rpx;
  margin-bottom: 24rpx;
  text-align: center;
  background: linear-gradient(135deg, #fff0e6, $card);
}
.bd-one-text {
  font-size: $fs-md;
  font-weight: 700;
  color: $primary;
  line-height: 1.6;
}
.bd-section {
  padding: 28rpx;
  margin-bottom: 24rpx;
}
.sec-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
  margin-bottom: 16rpx;
}
.sec-body {
  font-size: $fs-sm;
  color: $ink;
  line-height: $lh-base;
}
.idea {
  display: flex;
  gap: 16rpx;
  margin-bottom: 24rpx;
}
.idea:last-child {
  margin-bottom: 0;
}
.idea-no {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  background: $primary;
  color: #fff;
  font-size: $fs-xs;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.idea-body {
  flex: 1;
}
.idea-title {
  display: block;
  font-size: $fs-base;
  font-weight: 700;
  color: $ink;
  margin-bottom: 6rpx;
}
.idea-explain {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
}
.take {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  line-height: 2;
}
.rel-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}
.rel-chip {
  background: $primarySoft;
  border-radius: $radius-pill;
  padding: 10rpx 24rpx;
  font-size: $fs-sm;
  color: $primary;
  font-weight: 600;
}
</style>
