// Page-specific props interfaces — one per page, added per step

// auth/ResetPassword
export interface ResetPasswordProps {
  token: string
}

// profile/Edit
export interface ProfileEditProps {
  profile: {
    id: number
    name: string
    email: string
    phone: string | null
    whatsapp: string | null
    birthday: string | null
    country: string | null
    locale: string
    isMinor: boolean
    guardianName: string | null
    guardianEmail: string | null
    guardianPhone: string | null
    guardianWhatsapp: string | null
    profileComplete: boolean
  }
}
