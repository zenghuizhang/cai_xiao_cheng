<template>
  <view class="rv">
    <view class="rv-prog" v-if="!done">
      <text class="rv-label">复习队列 · 第 {{ pos + 1 }} / {{ work.length }} 张</text>
      <text class="rv-sub">还没吃透的卡片，再过一遍 🧠</text>
    </view>
    <ProgressBar v-if="!done" :read="pos" :total="work.length" />

    <view class="rv-stage" v-if="!done">
      <SwipeCard
        v-if="cur"
        :card="cur"
        @got="onMastered"
        @review="onStill"
        @glossary="onGlossary"
      />
    </view>

    <view v-if="done" class="rv-done">
      <OrangeMascot :size="180" mood="smile" />
      <text class="done-title">本轮复习完成 🎉</text>
      <text class="done-stat">本轮掌握 {{ roundMastered }} 张，队列还剩 {{ app.reviewCount }} 张</text>
      <view v-if="app.reviewCount" class="cx-btn-primary done-cta" @tap="restart">继续复习剩余</view>
      <view v-else class="cx-btn-primary done-cta" @tap="goLearn">全部掌握，回学习页</view>
    </view>

    <view v-if="!work.length && !done" class="rv-empty">
      <OrangeMascot :size="180" mood="smile" />
      <text class="empty-title">复习队列是空的 ✨</text>
      <text class="empty-sub">学习中遇到「没懂」的卡片会自动来到这里。保持手感，常回来看看。</text>
      <view class="cx-btn-primary empty-cta" @tap="goLearn">去学习</view>
    </view>

    <GlossarySheet :visible="glossaryVisible" @close="glossaryVisible = false" v-model:keyword="glossaryKw" />
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import ProgressBar from '@/components/ProgressBar.vue'
import SwipeCard from '@/components/SwipeCard.vue'
import GlossarySheet from '@/components/GlossarySheet.vue'
import OrangeMascot from '@/components/OrangeMascot.vue'
import { useAppStore } from '@/store/app'
import { getCard } from '@/utils/content'

const app = useAppStore()
const work = ref([]) // 本轮要复习的卡片 id 列表
const pos = ref(0)
const done = ref(false)
const roundMastered = ref(0)

const cur = computed(() => {
  const id = work.value[pos.value]
  return id ? getCard(id) : null
})

onShow(() => {
  startRound()
})

function startRound() {
  const ids = [...app.reviewQueue]
  work.value = ids
  pos.value = 0
  done.value = false
  roundMastered.value = 0
  if (!ids.length) done.value = true
}
function onMastered(cardId) {
  app.recordReview(cardId, true)
  roundMastered.value += 1
  advance()
}
function onStill(cardId) {
  app.recordReview(cardId, false)
  advance()
}
function advance() {
  setTimeout(() => {
    if (pos.value + 1 < work.value.length) {
      pos.value += 1
    } else {
      done.value = true
    }
  }, 200)
}
function restart() {
  startRound()
}
function goLearn() {
  uni.switchTab({ url: '/pages/learn/learn' })
}

const glossaryVisible = ref(false)
const glossaryKw = ref('')
function onGlossary(term) {
  glossaryKw.value = term
  glossaryVisible.value = true
}
</script>

<style lang="scss" scoped>
.rv {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.rv-prog {
  margin-bottom: 12rpx;
}
.rv-label {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
}
.rv-sub {
  font-size: $fs-xs;
  color: $ink2;
}
.rv-stage {
  margin-top: 24rpx;
}
.rv-done,
.rv-empty {
  margin-top: 120rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 0 32rpx;
}
.done-title,
.empty-title {
  font-size: $fs-lg;
  font-weight: 800;
  color: $ink;
  margin: 32rpx 0 12rpx;
}
.done-stat,
.empty-sub {
  font-size: $fs-sm;
  color: $ink2;
  line-height: $lh-base;
  margin-bottom: 40rpx;
}
.done-cta,
.empty-cta {
  width: 80%;
}
</style>
