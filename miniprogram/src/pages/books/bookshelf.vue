<template>
  <view class="bs">
    <view class="bs-note">
      <text class="bs-note-text">📚 {{ note }}</text>
    </view>
    <view
      v-for="b in books"
      :key="b.id"
      class="bk cx-card"
      @tap="open(b.id)"
    >
      <view class="bk-cover">
        <text class="bk-emoji">{{ b.cover_emoji }}</text>
      </view>
      <view class="bk-info">
        <view class="bk-title-row">
          <text class="bk-title">{{ b.title }}</text>
          <text class="bk-level">L{{ b.level }}</text>
        </view>
        <text class="bk-author">{{ b.author }}</text>
        <text class="bk-line">{{ b.one_line }}</text>
        <view class="bk-tags">
          <text v-for="t in b.tags" :key="t" class="bk-tag">{{ t }}</text>
        </view>
      </view>
      <text class="bk-arrow">›</text>
    </view>
    <view class="safe-bottom"></view>
  </view>
</template>

<script setup>
import { getBooks, getBooksNote } from '@/utils/content'
const books = getBooks()
const note = getBooksNote()
function open(id) {
  uni.navigateTo({ url: `/pages/books/book-detail?id=${id}` })
}
</script>

<style lang="scss" scoped>
.bs {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.bs-note {
  background: $primarySoft;
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
  margin-bottom: 24rpx;
}
.bs-note-text {
  font-size: $fs-xs;
  color: $ink2;
  line-height: $lh-base;
}
.bk {
  display: flex;
  align-items: center;
  gap: 24rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
}
.bk-cover {
  width: 112rpx;
  height: 144rpx;
  background: $primarySoft;
  border-radius: $radius-md;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.bk-emoji {
  font-size: 56rpx;
}
.bk-info {
  flex: 1;
  min-width: 0;
}
.bk-title-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
}
.bk-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.bk-level {
  font-size: $fs-xs;
  color: $primary;
  background: $card;
  border: 1rpx solid $line;
  padding: 2rpx 12rpx;
  border-radius: $radius-pill;
}
.bk-author {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.bk-line {
  display: block;
  font-size: $fs-sm;
  color: $ink;
  margin: 10rpx 0;
}
.bk-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
}
.bk-tag {
  font-size: 20rpx;
  color: $ink2;
  background: #f6f1ea;
  padding: 4rpx 14rpx;
  border-radius: $radius-pill;
}
.bk-arrow {
  font-size: 44rpx;
  color: $ink3;
  flex-shrink: 0;
}
</style>
