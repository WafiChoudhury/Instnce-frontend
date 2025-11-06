# Guide: Building Privy Funding Website

## Part 1: Understanding Privy SDK Differences

### `@privy-io/react-auth` vs `@privy-io/expo`

**TL;DR: You want `@privy-io/react-auth` for a web page**

#### `@privy-io/react-auth` (FOR WEB)
- **Platform:** Web browsers (React web apps)
- **Use case:** Your hosted funding page
- **Why it fits:** Standard React hooks, works in any browser
- **Auth methods:** Email, Google, WalletConnect, etc.
- **Wallet funding:** `useFundSolanaWallet()` hook
- **Install:** `npm install @privy-io/react-auth`

#### `@privy-io/expo` (FOR NATIVE MOBILE)
- **Platform:** React Native (iOS/Android native apps)
- **Use case:** Building native mobile apps
- **Why NOT for us:** We're building a **web page** to embed
- **Auth methods:** Phone SMS, biometrics, native-specific
- **Wallet funding:** `useFundSolanaWallet()` from `@privy-io/expo/ui`
- **Install:** `npm install @privy-io/expo`

**Decision:** Use **`@privy-io/react-auth`** for your funding website ✅

---

## Part 2: Instructions for LLM to Build Website

Copy this entire section to another LLM (Claude/GPT-4):

---

# Task: Build Privy Funding Web Page

I need a simple React web page that allows users to fund their Solana wallet using Privy's embedded wallet funding.

## Requirements

### Tech Stack
- **Framework:** React (Vite recommended for fast dev server)
- **Library:** `@privy-io/react-auth` (NOT expo)
- **Deploy:** Vercel or Netlify (free hosting)

### User Flow
1. User lands on page with wallet address in URL params
2. Page auto-initializes Privy with app ID
3. User clicks "Fund Wallet" button
4. Privy's funding UI appears with Apple Pay, cards, etc.
5. After funding, redirect to `instnce://onramp-complete` to return to iOS app

### URL Parameters
```
https://your-domain.com?address=WALLET_ADDRESS&amount=0.1
```

### Privy Configuration
- **App ID:** `cmh2vmapv047bif0c19sx0v6r`
- **Network:** Solana mainnet (`mainnet-beta`)
- **Asset:** SOL (native)

### Code Requirements

```jsx
// Minimal React app with:
import { PrivyProvider, usePrivy, useFundSolanaWallet } from '@privy-io/react-auth'

// Components needed:
// 1. App shell with PrivyProvider wrapper
// 2. Funding component that:
//    - Reads address/amount from URL params
//    - Shows wallet address (truncated)
//    - Has "Fund Wallet" button
//    - Calls fundWallet() on click
//    - Handles redirect back to app
//    - Shows loading/success states
```

### Visual Design
- Clean, minimalist UI
- Modern card-based layout
- Show truncated wallet address (first 8 + last 8 chars)
- Large, prominent "Fund Wallet" button
- Loading spinner during funding flow
- Success message after completion

### Edge Cases
- If no address param → show error
- If Privy not ready → show loading
- If not authenticated → ask to sign in
- If funding fails → show error message

### Testing
- Should work on iOS Safari (embedded in WebView)
- Should handle `instnce://` redirect
- Should pass address to Privy correctly

### Deliverables
1. Complete React source code
2. `package.json` with dependencies
3. Build/deployment instructions
4. Installation commands

---

## Part 3: Key Code Snippets

### Basic Structure

```jsx
import { PrivyProvider, usePrivy, useFundSolanaWallet } from '@privy-io/react-auth'

function FundingApp() {
  const { ready, authenticated } = usePrivy()
  const { fundWallet } = useFundSolanaWallet()
  
  // Get params from URL
  const params = new URLSearchParams(window.location.search)
  const address = params.get('address')
  const amount = params.get('amount') || '0.1'
  
  const handleFund = async () => {
    await fundWallet({
      address: address,
      amount: amount,
      cluster: { name: 'mainnet-beta' }
    })
    
    // Redirect back
    window.location.href = 'instnce://onramp-complete'
  }
  
  return (
    <button onClick={handleFund}>Fund Wallet</button>
  )
}

function App() {
  return (
    <PrivyProvider appId="cmh2vmapv047bif0c19sx0v6r">
      <FundingApp />
    </PrivyProvider>
  )
}
```

---

## Part 4: After Website is Built

### Integration Checklist
1. ✅ Deploy website to Vercel/Netlify
2. ✅ Update `OnrampView.swift` line 53 with your URL
3. ✅ Test in iOS app
4. ✅ Enable funding in Privy Dashboard

### Privy Dashboard Setup
1. Go to Privy Dashboard
2. Navigate to "User Management" → "Account Funding"
3. Enable "Pay with card"
4. Configure network: Solana mainnet
5. Set recommended amount (optional)

---

## Summary

**What you're building:** A simple React web page hosted online  
**What it does:** Lets users fund their Privy Solana wallet via card/Apple Pay  
**How it connects:** iOS app opens this page in WKWebView  
**Why this works:** Privy handles all KYC, payments, compliance  

**Next:** Give Part 2 to an LLM to generate the actual website code 🚀

