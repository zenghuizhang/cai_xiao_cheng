<template>
  <view class="mascot" :style="{ width: size + 'rpx', height: size + 'rpx' }">
    <!-- 叶子 -->
    <view class="leaf"></view>
    <!-- 橙子身体 -->
    <view class="body">
      <!-- 高光 -->
      <view class="shine"></view>
      <!-- 眼睛 -->
      <view class="eyes">
        <view class="eye eye-l">
          <view class="pupil"></view>
        </view>
        <view class="eye eye-r">
          <view class="pupil"></view>
        </view>
      </view>
      <!-- 腮红 -->
      <view class="blush blush-l"></view>
      <view class="blush blush-r"></view>
      <!-- 嘴 -->
      <view class="mouth" :class="'mouth-' + mood"></view>
    </view>
  </view>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 140 },
  mood: { type: String, default: 'smile' }, // smile | open | think
})
</script>

<style lang="scss" scoped>
.mascot {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}
.body {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: radial-gradient(circle at 32% 30%, #ffb37a 0%, #ff8c42 55%, #e5732a 100%);
  box-shadow: 0 10rpx 30rpx rgba(229, 115, 42, 0.28);
  overflow: hidden;
}
.shine {
  position: absolute;
  top: 12%;
  left: 18%;
  width: 26%;
  height: 20%;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.45);
  filter: blur(2rpx);
}
.leaf {
  position: absolute;
  top: -6%;
  left: 50%;
  width: 22%;
  height: 22%;
  margin-left: -6%;
  background: #6fb47a;
  border-radius: 0 60% 0 60%;
  transform: rotate(35deg);
  z-index: 2;
  box-shadow: inset -2rpx -2rpx 6rpx rgba(0, 0, 0, 0.08);
}
.eyes {
  position: absolute;
  top: 36%;
  left: 0;
  width: 100%;
  display: flex;
  justify-content: center;
  gap: 16%;
}
.eye {
  width: 14%;
  height: 18%;
  border-radius: 50%;
  background: #3d2b1f;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
}
.eye-l {
  align-items: flex-start;
  justify-content: flex-start;
}
.pupil {
  width: 36%;
  height: 36%;
  border-radius: 50%;
  background: #fff;
  margin: 18% 18% 0 0;
}
.eye-l .pupil {
  margin: 18% 0 0 18%;
}
.blush {
  position: absolute;
  top: 56%;
  width: 14%;
  height: 10%;
  border-radius: 50%;
  background: rgba(229, 106, 92, 0.4);
}
.blush-l {
  left: 20%;
}
.blush-r {
  right: 20%;
}
.mouth {
  position: absolute;
  top: 62%;
  left: 50%;
  transform: translateX(-50%);
  border: 4rpx solid #3d2b1f;
  border-top: none;
  border-left: none;
  border-right: none;
}
.mouth-smile {
  width: 26%;
  height: 12%;
  border-radius: 0 0 60% 60%;
  border-bottom-width: 5rpx;
}
.mouth-open {
  width: 18%;
  height: 14%;
  border-radius: 50%;
  background: #7a3b2a;
  border: 4rpx solid #3d2b1f;
}
.mouth-think {
  width: 14%;
  height: 8%;
  border-radius: 0 0 50% 50%;
  border-bottom-width: 5rpx;
  transform: translateX(-30%);
}
</style>
