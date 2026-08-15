<template>
  <view class="calc">
    <view class="calc-card cx-card">
      <text class="calc-card-title">🎛️ 假设参数</text>

      <view class="field">
        <view class="field-head">
          <text class="field-label">一次性本金</text>
          <text class="field-val">{{ formatYuan(principal, 0) }}</text>
        </view>
        <slider
          :value="principal"
          :min="0"
          :max="1000000"
          :step="1000"
          activeColor="#ff8c42"
          backgroundColor="#ffe3cf"
          block-color="#ff8c42"
          @change="(e) => (principal = e.detail.value)"
        />
      </view>

      <view class="field">
        <view class="field-head">
          <text class="field-label">年化收益率</text>
          <text class="field-val">{{ annualRate }}%</text>
        </view>
        <slider
          :value="annualRate"
          :min="0"
          :max="20"
          :step="0.5"
          activeColor="#ff8c42"
          backgroundColor="#ffe3cf"
          block-color="#ff8c42"
          @change="(e) => (annualRate = e.detail.value)"
        />
      </view>

      <view class="field">
        <view class="field-head">
          <text class="field-label">投资年数</text>
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
      <text class="result-emoji">📈</text>
      <text class="result-label">{{ years }} 年后预计变成</text>
      <text class="result-num">{{ formatYuan(fv, 2) }}</text>
      <view class="result-grid">
        <view class="rg-item">
          <text class="rg-num">{{ formatSigned(gain) }}</text>
          <text class="rg-label">收益（元）</text>
        </view>
        <view class="rg-item">
          <text class="rg-num">{{ doubleText }}</text>
          <text class="rg-label">本金翻倍约需</text>
        </view>
      </view>
    </view>

    <view class="series cx-card">
      <text class="series-title">📊 逐年增长（假设收益率推演）</text>
      <view class="series-row series-head">
        <text class="c-year">年份</text>
        <text class="c-total">账户总额</text>
        <text class="c-gain">累计收益</text>
      </view>
      <view v-for="row in series" :key="row.year" class="series-row">
        <text class="c-year">{{ row.year === 0 ? '起' : row.year + '年' }}</text>
        <text class="c-total">{{ formatWan(row.total) }}</text>
        <text class="c-gain" :class="{ pos: row.gain > 0 }">{{ formatSigned(row.gain) }}</text>
      </view>
    </view>

    <Disclaimer variant="warn" title="教学说明" icon="⚠️" text="以上为固定假设收益率下的数学推演，真实收益会波动甚至亏损。不构成任何投资建议，不代表对未来收益的预测。" />
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { lumpSum, dcaYearlySeries, doubleYears } from '@/utils/finance'
import { formatYuan, formatWan, formatSigned } from '@/utils/format'

const principal = ref(100000)
const annualRate = ref(8)
const years = ref(10)

const fv = computed(() => lumpSum({ principal: principal.value, annualRate: annualRate.value, years: years.value }))
const gain = computed(() => fv.value - principal.value)
const series = computed(() =>
  dcaYearlySeries({ principal: principal.value, monthly: 0, annualRate: annualRate.value, years: years.value })
)
const doubleText = computed(() => {
  const y = doubleYears(annualRate.value)
  return y === Infinity ? '不会翻倍' : `约 ${y.toFixed(1)} 年`
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
  color: $primary;
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
.rg-label {
  display: block;
  font-size: $fs-xs;
  color: $ink2;
  margin-top: 4rpx;
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
.c-total {
  flex: 1;
  color: $ink;
  font-weight: 600;
}
.c-gain {
  width: 180rpx;
  text-align: right;
  color: $ink3;
}
.c-gain.pos {
  color: $success;
  font-weight: 600;
}
</style>
