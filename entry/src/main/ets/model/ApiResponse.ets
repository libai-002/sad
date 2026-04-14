export interface ApiResponse<T> {
  message?: string;
  userId?: number;
  username?: string;
  role?: string;
  data?: T;
  error?: string | Record<string, string>;
  errors?: Record<string, string>;
}