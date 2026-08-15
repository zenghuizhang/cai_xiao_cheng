<template>
  <view class="lg">
    <PageHeader title="登录" :show-back="true" />

    <view class="lg-hero">
      <OrangeMascot :size="160" mood="smile" />
      <text class="lg-title">登录财小橙</text>
      <text class="lg-sub">登录后可跨设备同步学习进度</text>
    </view>

    <view v-if="!user.cloudAvailable" class="lg-warn">
      <text>⚠️ 云端服务暂未连接，登录功能不可用。可先以游客模式学习，进度保存在本地。</text>
    </view>

    <!-- 微信小程序：微信登录 + 手机号一键登录 -->
    <!-- #ifdef MP-WEIXIN -->
    <view class="lg-methods">
      <view class="cx-btn-primary lg-btn" :class="{ disabled: !agreed || user.loginLoading }" @tap="onWeixin">
        <text>{{ user.loginLoading ? '登录中…' : '💚 微信一键登录' }}</text>
      </view>
      <button
        class="lg-phone-btn"
        open-type="getPhoneNumber"
        :disabled="!agreed || user.loginLoading"
        @getphonenumber="onGetPhoneNumber"
      >
        📱 手机号一键登录
      </button>
    </view>
    <!-- #endif -->

    <!-- 通用 / H5 / APP：短信验证码登录 -->
    <!-- #ifndef MP-WEIXIN -->
    <view class="lg-form cx-card">
      <view class="fm-row">
        <text class="fm-prefix">+86</text>
        <input
          v-model="phone"
          class="fm-input"
          type="number"
          maxlength="11"
          placeholder="请输入手机号"
        />
      </view>
      <!-- 图形验证码（uni-id sendSmsCode / loginBySms 要求） -->
      <view class="fm-row">
        <input
          v-model="captchaInput"
          class="fm-input"
          type="text"
          maxlength="6"
          placeholder="图形验证码"
        />
        <image
          v-if="captchaImg"
          class="fm-captcha"
          :src="captchaImg"
          mode="aspectFit"
          @tap="refreshCaptcha"
        />
        <view v-else class="fm-captcha fm-captcha-loading" @tap="refreshCaptcha">加载</view>
      </view>
      <view class="fm-row">
        <input
          v-model="smsCode"
          class="fm-input"
          type="number"
          maxlength="6"
          placeholder="短信验证码"
        />
        <view
          class="fm-code"
          :class="{ disabled: counting || !phoneOk || !captchaInput }"
          @tap="onSendCode"
        >
          {{ counting ? `${countdown}s` : '获取验证码' }}
        </view>
      </view>
      <view
        class="cx-btn-primary lg-btn"
        :class="{ disabled: !agreed || !phoneOk || !smsCode || !captchaInput || user.loginLoading }"
        @tap="onSmsLogin"
      >
        <text>{{ user.loginLoading ? '登录中…' : '登录' }}</text>
      </view>
    </view>
    <!-- #endif -->

    <view class="lg-agree">
      <view class="ag-check" :class="{ on: agreed }" @tap="agreed = !agreed">
        <text v-if="agreed" class="ag-tick">✓</text>
      </view>
      <text class="ag-text" @tap="agreed = !agreed">
        我已阅读并同意《用户协议》与《隐私政策》，知悉本应用为纯教育产品，不提供投资建议。
      </text>
    </view>

    <view class="lg-tip">
      <text>游客也可完整使用，登录仅用于进度同步。不会向你推荐任何理财产品。</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import PageHeader from '@/components/PageHeader.vue'
import OrangeMascot from '@/components/OrangeMascot.vue'
import { useUserStore } from '@/store/user'

const user = useUserStore()
const agreed = ref(false)
const phone = ref('')
const smsCode = ref('')
const captchaInput = ref('')
const captchaImg = ref('')
const counting = ref(false)
const countdown = ref(60)

const phoneOk = computed(() => /^1\d{10}$/.test(phone.value))

/** 拉取图形验证码（uni-id sendSmsCode / loginBySms 要求）。 */
async function refreshCaptcha() {
  try {
    const r = await user.getCaptcha()
    // uni-id-co.createCaptcha 返回 { captchaBase64, captchaId } 或类似结构
    captchaImg.value = (r && (r.captchaBase64 || r.captcha || r.image)) || ''
  } catch (e) {
    captchaImg.value = ''
  }
}

onMounted(() => {
  refreshCaptcha()
})

let timer = null
function startCountdown() {
  counting.value = true
  countdown.value = 60
  timer = setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0) {
      counting.value = false
      clearInterval(timer)
    }
  }, 1000)
}

function ensureAgreed() {
  if (!agreed.value) {
    uni.showToast({ title: '请先同意用户协议', icon: 'none' })
    return false
  }
  return true
}

function successBack() {
  uni.showToast({ title: '登录成功', icon: 'success' })
  setTimeout(() => {
    uni.navigateBack({ delta: 1, fail: () => uni.switchTab({ url: '/pages/mine/mine' }) })
  }, 600)
}

// #ifdef MP-WEIXIN
async function onWeixin() {
  if (!ensureAgreed() || user.loginLoading) return
  try {
    await user.loginByWeixin()
    successBack()
  } catch (e) {
    uni.showToast({ title: e.message || '登录失败', icon: 'none' })
  }
}
async function onGetPhoneNumber(e) {
  if (!ensureAgreed()) return
  const code = e.detail && e.detail.code
  if (!code) {
    uni.showToast({ title: '未获取到手机号', icon: 'none' })
    return
  }
  try {
    await user.loginByPhone(code)
    successBack()
  } catch (err) {
    uni.showToast({ title: err.message || '登录失败', icon: 'none' })
  }
}
// #endif

// #ifndef MP-WEIXIN
async function onSendCode() {
  if (counting.value || !phoneOk.value || !captchaInput.value) {
    if (!phoneOk.value) uni.showToast({ title: '请输入正确手机号', icon: 'none' })
    else if (!captchaInput.value) uni.showToast({ title: '请输入图形验证码', icon: 'none' })
    return
  }
  try {
    await user.sendSmsCode(phone.value, captchaInput.value)
    uni.showToast({ title: '验证码已发送', icon: 'none' })
    startCountdown()
  } catch (e) {
    uni.showToast({ title: e.message || '发送失败', icon: 'none' })
    refreshCaptcha() // 失败后刷新图形验证码
  }
}
async function onSmsLogin() {
  if (!ensureAgreed() || !phoneOk.value || !smsCode.value || !captchaInput.value || user.loginLoading) return
  try {
    await user.loginBySmsCode(phone.value, smsCode.value, captchaInput.value)
    successBack()
  } catch (e) {
    uni.showToast({ title: e.message || '登录失败', icon: 'none' })
    refreshCaptcha()
  }
}
// #endif
</script>

<style lang="scss" scoped>
.lg {
  min-height: 100vh;
  background: $cream;
  display: flex;
  flex-direction: column;
}
.lg-hero {
  text-align: center;
  padding: 32rpx 0 48rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.lg-title {
  font-size: $fs-xl;
  font-weight: 800;
  color: $ink;
  margin-top: 20rpx;
}
.lg-sub {
  font-size: $fs-sm;
  color: $ink2;
  margin-top: 8rpx;
}
.lg-warn {
  margin: 0 32rpx 24rpx;
  background: $dangerSoft;
  border-left: 6rpx solid $danger;
  border-radius: $radius-md;
  padding: 20rpx 24rpx;
}
.lg-warn text {
  font-size: $fs-xs;
  color: $ink;
  line-height: $lh-base;
}
.lg-methods {
  padding: 0 48rpx;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}
.lg-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.lg-btn.disabled {
  opacity: 0.5;
}
.lg-phone-btn {
  width: 100%;
  height: 96rpx;
  line-height: 96rpx;
  background: $card;
  color: $ink;
  border: 2rpx solid $primary;
  border-radius: $radius-pill;
  font-size: $fs-md;
  font-weight: 700;
  text-align: center;
}
.lg-phone-btn::after {
  border: none;
}
.lg-phone-btn[disabled] {
  opacity: 0.5;
}
.lg-form {
  margin: 0 32rpx;
  padding: 32rpx;
}
.fm-row {
  display: flex;
  align-items: center;
  border-bottom: 1rpx solid $line;
  padding: 20rpx 0;
}
.fm-prefix {
  font-size: $fs-md;
  color: $ink;
  font-weight: 700;
  margin-right: 20rpx;
}
.fm-input {
  flex: 1;
  font-size: $fs-base;
  color: $ink;
}
.fm-code {
  font-size: $fs-sm;
  color: $primary;
  font-weight: 600;
  padding: 8rpx 0 8rpx 20rpx;
  border-left: 1rpx solid $line;
  margin-left: 16rpx;
  white-space: nowrap;
}
.fm-code.disabled {
  color: $ink3;
}
.fm-captcha {
  width: 160rpx;
  height: 64rpx;
  border-radius: $radius-sm;
  border: 1rpx solid $line;
  background: $card;
  flex-shrink: 0;
  margin-left: 16rpx;
}
.fm-captcha-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $fs-xs;
  color: $ink2;
}
.lg-form .lg-btn {
  margin-top: 32rpx;
}
.lg-agree {
  display: flex;
  align-items: flex-start;
  gap: 12rpx;
  padding: 32rpx 48rpx 16rpx;
}
.ag-check {
  width: 36rpx;
  height: 36rpx;
  border: 2rpx solid $ink3;
  border-radius: 8rpx;
  flex-shrink: 0;
  margin-top: 4rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.ag-check.on {
  background: $primary;
  border-color: $primary;
}
.ag-tick {
  color: #fff;
  font-size: 24rpx;
  font-weight: 800;
}
.ag-text {
  font-size: $fs-xs;
  color: $ink2;
  line-height: 1.6;
  flex: 1;
}
.lg-tip {
  text-align: center;
  padding: 16rpx 64rpx;
}
.lg-tip text {
  font-size: 20rpx;
  color: $ink3;
  line-height: $lh-base;
}
</style>
