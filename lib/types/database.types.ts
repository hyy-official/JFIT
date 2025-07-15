// Auto-generated Supabase Database Types
// Generated from project: mdjsjdxvumdxjulgemhg
// Last updated: 2025-07-15

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      exercises: {
        Row: {
          id: string
          title_ko: string
          title_en: string | null
          desc_ko: string | null
          desc_en: string | null
          difficulty: string | null
          difficulty_ko: string | null
          type: string | null
          type_ko: string | null
          equipment: string | null
          equipment_ko: string | null
          calories_per_minute: number | null
          met_value: number | null
          primary_muscles: string | null
          primary_muscles_ko: string | null
          secondary_muscles: string | null
          secondary_muscles_ko: string | null
          category_ko: string | null
          category_en: string | null
          recommended_sets: string | null
          recommended_reps: string | null
          recommended_rest_seconds: number | null
          is_active: boolean | null
          popularity_score: number | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string
          title_ko: string
          title_en?: string | null
          desc_ko?: string | null
          desc_en?: string | null
          difficulty?: string | null
          difficulty_ko?: string | null
          type?: string | null
          type_ko?: string | null
          equipment?: string | null
          equipment_ko?: string | null
          calories_per_minute?: number | null
          met_value?: number | null
          primary_muscles?: string | null
          primary_muscles_ko?: string | null
          secondary_muscles?: string | null
          secondary_muscles_ko?: string | null
          category_ko?: string | null
          category_en?: string | null
          recommended_sets?: string | null
          recommended_reps?: string | null
          recommended_rest_seconds?: number | null
          is_active?: boolean | null
          popularity_score?: number | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string
          title_ko?: string
          title_en?: string | null
          desc_ko?: string | null
          desc_en?: string | null
          difficulty?: string | null
          difficulty_ko?: string | null
          type?: string | null
          type_ko?: string | null
          equipment?: string | null
          equipment_ko?: string | null
          calories_per_minute?: number | null
          met_value?: number | null
          primary_muscles?: string | null
          primary_muscles_ko?: string | null
          secondary_muscles?: string | null
          secondary_muscles_ko?: string | null
          category_ko?: string | null
          category_en?: string | null
          recommended_sets?: string | null
          recommended_reps?: string | null
          recommended_rest_seconds?: number | null
          is_active?: boolean | null
          popularity_score?: number | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      user_profiles: {
        Row: {
          id: string
          email: string
          username: string | null
          full_name: string | null
          profile_photo_url: string | null
          timezone: string | null
          fitness_goal: string | null
          daily_calorie_goal: number | null
          unit_preference: string | null
          gender: string | null
          date_of_birth: string | null
          bio: string | null
          is_active: boolean | null
          is_verified: boolean
          receive_notifications: boolean | null
          created_at: string | null
          updated_at: string | null
          last_login_at: string | null
        }
        Insert: {
          id?: string
          email: string
          username?: string | null
          full_name?: string | null
          profile_photo_url?: string | null
          timezone?: string | null
          fitness_goal?: string | null
          daily_calorie_goal?: number | null
          unit_preference?: string | null
          gender?: string | null
          date_of_birth?: string | null
          bio?: string | null
          is_active?: boolean | null
          is_verified?: boolean
          receive_notifications?: boolean | null
          created_at?: string | null
          updated_at?: string | null
          last_login_at?: string | null
        }
        Update: {
          id?: string
          email?: string
          username?: string | null
          full_name?: string | null
          profile_photo_url?: string | null
          timezone?: string | null
          fitness_goal?: string | null
          daily_calorie_goal?: number | null
          unit_preference?: string | null
          gender?: string | null
          date_of_birth?: string | null
          bio?: string | null
          is_active?: boolean | null
          is_verified?: boolean
          receive_notifications?: boolean | null
          created_at?: string | null
          updated_at?: string | null
          last_login_at?: string | null
        }
      }
      // 다른 테이블들도 필요시 추가 가능
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      get_nutrition_data: {
        Args: { user_id_param: string }
        Returns: {
          meal_date: string
          total_calories: number
          total_protein: number
          total_carbs: number
          total_fat: number
        }[]
      }
      get_workout_time_data: {
        Args: { user_id_param: string }
        Returns: {
          workout_date: string
          total_duration: number
        }[]
      }
    }
    Enums: {
      food_type: "processed" | "fresh"
    }
  }
}

// 편의 타입들
export type Tables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Row']
export type TablesInsert<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Insert']
export type TablesUpdate<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Update']

// 자주 사용되는 타입들
export type Exercise = Tables<'exercises'>
export type UserProfile = Tables<'user_profiles'>
export type WorkoutProgram = Tables<'workout_programs'>
export type UserProgram = Tables<'user_programs'>
export type WorkoutSession = Tables<'workout_sessions'>
export type FoodItem = Tables<'food_items'>
export type UserMealEntry = Tables<'user_meal_entries'>