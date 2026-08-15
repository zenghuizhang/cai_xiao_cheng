<template>
  <view class="calc">
    <view class="calc-card cx-card">
      <text class="calc-card-title">🎛️ 假设参数</text>

      <view class="field">
        <view class="field-head">
          <text class="field-label">现在的钱</text>
          <text class="field-val">{{ formatYuan(money, 0) }}</text>
        </view>
        <slider
          :value="money"
          :min="1000"
          :max="1000000"
          :step="1000"
          activeColor="#ff8c42"
          backgroundColor="#ffe3cf"
          block-color="#ff8c42"
          @change="(e) => (money = e.detail.value)"
        />
      </view>

      <view class="field">
        <view class="field-head">
          <text class="field-label">年通胀率</text>
          <text class="field-val">{{ inflation }}%</text>
        </view>
        <slider
          :value="inflation"
          :min="0"
          :max="10"
          :step="0.2"
          activeColor="#ff8c42"
          backgroundColor="#ffe3cf"
          block-color="#ff8c42"
          @change="(e) => (inflation = e.detail.value)"
        />
      </view>

      <view class="field">
        <view class="field-head">
          <text class="field-label">放多少年</text>
          <text class="field-val">{{ years }} 年</text>
        </view>
        <slider
          :value="years"
          :min="1"
          :max="40"
          :step="1"
          activeColor="#ff8c42"
          backgroundColor="#ffe3cf"
          block-color="#ff8c42"
          @change="(e) => (years = e.detail.value)"
        />
      </view>
    </view>

    <view class="result-card cx-card">
      <text class="result-emoji">🫠</text>
      <text class="result-label">{{ years }} 年后，这笔钱的实际购买力约等于</text>
      <text class="result-num">{{ formatYuan(pp, 2) }}</text>
      <view class="result-grid">
        <view class="rg-item">
          <text class="rg-num neg">{{ formatYuan(loss, 0) }}</text>
          <text class="rg-label">购买力缩水</text>
        </view>
        <view class="rg-item">
          <text class="rg-num neg">{{ lossPct }}%</text>
          <text class="rg-label">缩水比例</text>
        </view>
      </view>
      <text class="result-tip">钱没少，但能买到的东西少了——这就是通胀的「隐形小偷」。</text>
    </view>

    <view class="series cx-card">
      <text class="series-title">📊 逐年购买力衰减</text>
      <view class="series-row series-head">
        <text class="c-year">年份</text>
        <text class="c-pp">实际购买力</text>
        <text class="c-loss">较今天</text>
      </view>
      <view v-for="row in series" :key="row.year" class="series-row">
        <text class="c-year">{{ row.year }}年</text>
        <text class="c-pp">{{ formatYuan(row.pp, 0) }}</text>
        <text class="c-loss neg">{{ row.lossPct }}%</text>
      </view>
    </view>

    <Disclaimer variant="plain" title="教学说明" icon="💡" text="通胀率为假设值，实际通胀年年不同。本工具用于直观感受「钱放着不动」的购买力流失，不构成任何投资建议。" />
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { purchasingPower } from '@/utils/finance'
import { formatYuan } from '@/utils/format'

const money = ref(100000)
const inflation = ref(3)
const years = ref(20)

const pp = computed(() => purchasingPower({ money: money.value, inflation: inflation.value, years: years.value }))
const loss = computed(() => money.value - pp.value)
const lossPct = computed(() => Math.round(((money.value - pp.value) / money.value) * 100))
const series = computed(() => {
  const out = []
  for (let y = 1; y <= years.value; y++) {
    const p = purchasingPower({ money: money.value, inflation: inflation.value, years: y })
    out.push({
      year: y,
      pp: p,
      lossPct: Math.round(((money.value - p) / money.value) * 100),
    })
  }
  return out
})
</script>

<style lang="scss" scoped>
.calc {
  min-height: 100vh;
  background: $cream;
  padding: 24rpx 32rpx;
}
.calc-card {
  padding: 32rpx;
  margin-bottom: 24rpx;
}
.calc-card-title {
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
  display: block;
  margin-bottom: 24rpx;
}
.field {
  margin-bottom: 28rpx;
}
.field:last-child {
  margin-bottom: 0;
}
.field-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 12rpx;
}
.field-label {
  font-size: $fs-sm;
  color: $ink2;
}
.field-val {
  font-size: $fs-md;
  font-weight: 800;
  color: $primary;
}
.result-card {
  padding: 40rpx 32rpx;
  text-align: center;
  background: linear-gradient(135deg, #fff0e6, $card);
  margin-bottom: 24rpx;
}
.result-emoji {
  font-size: 64rpx;
}
.result-label {
  display: block;
  font-size: $fs-sm;
  color: $ink2;
  margin: 12rpx 0 8rpx;
}
.result-num {
  display: block;
  font-size: 56rpx;
  font-weight: 800;
  color: $danger;
  line-height: 1.2;
}
.result-grid {
  display: flex;
  margin-top: 32rpx;
  padding-top: 28rpx;
  border-top: 1rpx solid $line;
}
.rg-item {
  flex: 1;
}
.rg-num {
  display: block;
  font-size: $fs-md;
  font-weight: 700;
  color: $ink;
}
.rg-num.neg {
  color: $danger;
}
.rg-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
}
.result-tip {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 24rpx;
  line-height: $lh-base;
}
.series {
  padding: 28rpx 24rpx;
  margin-bottom: 24rpx;
}
.series-title {
  font-size: $fs-sm;
  font-weight: 700;
  color: $ink;
  display: block;
  margin-bottom: 16rpx;
}
.series-row {
  display: flex;
  padding: 14rpx 8rpx;
  border-bottom: 1rpx solid $line;
  font-size: $fs-sm;
}
.series-row:last-child {
  border-bottom: none;
}
.series-head {
  color: $ink3;
  font-size: $fs-xs;
}
.c-year {
  width: 120rpx;
  color: $ink2;
}
.c-pp {
  flex: 1;
  color: $ink;
  font-weight: 600;
}
.c-loss {
  width: 180rpx;
  text-align: right;
  color: $ink3;
}
.c-loss.neg {
  color: $danger;
  font-weight: 600;
}
</style>
