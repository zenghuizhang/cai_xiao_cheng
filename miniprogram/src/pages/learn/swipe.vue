<template>
  <view class="sp">
    <PageHeader title="知识卡片" :show-back="true" />
    <view class="sp-prog">
      <view class="sp-prog-head">
        <text class="sp-prog-label">{{ chapter ? chapter.title : '学习中' }}</text>
        <text class="sp-prog-num">{{ done }} / {{ cards.length }} 张</text>
      </view>
      <ProgressBar :read="done" :total="cards.length" />
    </view>

    <view class="sp-stage">
      <SwipeCard
        v-if="cur"
        :card="cur"
        @got="onGot"
        @review="onReview"
        @glossary="onGlossary"
      />
      <view v-else class="empty">
        <OrangeMascot :size="160" mood="open" />
        <text class="empty-title">本章卡片已读完 🎉</text>
        <text class="empty-sub">{{ readCount }} 张已懂，去闯关测验检验一下吧</text>
        <view class="cx-btn-primary empty-cta" @tap="goQuiz">去闯关测验 🎯</view>
      </view>
    </view>

    <GlossarySheet :visible="glossaryVisible" @close="glossaryVisible = false" v-model:keyword="glossaryKw" />
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import PageHeader from '@/components/PageHeader.vue'
import ProgressBar from '@/components/ProgressBar.vue'
import SwipeCard from '@/components/SwipeCard.vue'
import GlossarySheet from '@/components/GlossarySheet.vue'
import OrangeMascot from '@/components/OrangeMascot.vue'
import { useAppStore } from '@/store/app'
import { getChapter, getCardsByChapter } from '@/utils/content'

const app = useAppStore()
const chapterId = ref('')
const cards = ref([])
const chapter = ref(null)
const idx = ref(0)

onLoad((options) => {
  chapterId.value = options.chapter
  chapter.value = getChapter(options.chapter)
  cards.value = getCardsByChapter(options.chapter)
})

const cur = computed(() => cards.value[idx.value] || null)
const done = computed(() => Math.min(idx.value, cards.value.length))
const readCount = computed(() => {
  const oid = (chapter.value || {}).order_index
  return app.progress.cards_read.filter((id) => {
    const c = cards.value.find((x) => x.id === id)
    return c && c.chapter === oid
  }).length
})

const glossaryVisible = ref(false)
const glossaryKw = ref('')

function onGot(cardId) {
  const card = cards.value.find((c) => c.id === cardId)
  app.recordCard(cardId, 'got', card ? card.points : 0)
  advance()
}
function onReview(cardId) {
  app.recordCard(cardId, 'review', 0)
  advance()
}
function advance() {
  setTimeout(() => {
    if (idx.value < cards.value.length) idx.value += 1
  }, 200)
}
function onGlossary(term) {
  glossaryKw.value = term
  glossaryVisible.value = true
}
function goQuiz() {
  uni.redirectTo({ url: `/pages/learn/quiz?chapter=${chapterId.value}` })
}
</script>

<style lang="scss" scoped>
.sp {
  min-height: 100vh;
  background: $cream;
  display: flex;
  flex-direction: column;
}
.sp-prog {
  padding: 8rpx 32rpx 16rpx;
}
.sp-prog-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.sp-prog-label {
  font-size: $fs-sm;
  font-weight: 700;
  color: $ink;
}
.sp-prog-num {
  font-size: $fs-xs;
  color: $ink2;
}
.sp-stage {
  flex: 1;
  padding: 24rpx 32rpx 0;
  display: flex;
  flex-direction: column;
}
.empty {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 0 32rpx;
}
.empty-title {
  font-size: $fs-lg;
  font-weight: 800;
  color: $ink;
  margin: 32rpx 0 12rpx;
}
.empty-sub {
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
  margin-bottom: 40rpx;
}
.empty-cta {
  width: 80%;
}
</style>
