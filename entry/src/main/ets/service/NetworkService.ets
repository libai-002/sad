import { hilog } from '@kit.PerformanceAnalysisKit';
import http from '@ohos.net.http';
import { AuthService } from './AuthService';

/**
 * 通用参数类型，支持任意字符串键
 */
type ParamsObject = Record<string, string | number | boolean | null | undefined>;

const DOMAIN = 0x0000;

export class NetworkService {
  // 配置后端服务的基础URL，包含8081端口
  private static readonly BASE_URL: string = 'http://10.0.2.2:8081';

  /**
   * 获取认证令牌
   * @returns string | undefined 认证令牌
   */
  private static getAuthToken(): string | undefined {
    return AuthService.getToken();
  }

  /**
   * 构建请求头
   * @returns Record<string, string> 请求头
   */
  private static buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    
    // 添加认证令牌
    const token = NetworkService.getAuthToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    
    return headers;
  }

  /**
   * 发送GET请求
   * @param path API路径
   * @param params 请求参数，可以是对象或单个字符串
   * @returns Promise<T> 响应数据
   */
  static async get<T>(path: string, params?: ParamsObject | string): Promise<T> {
    const url = NetworkService.buildUrl(path, params);
    let httpRequest: http.HttpRequest = http.createHttp();
    try {
      // 使用Promise包装HTTP请求
      return await new Promise<T>((resolve, reject) => {
        httpRequest.request(
          url,
          {
            method: http.RequestMethod.GET,
            header: NetworkService.buildHeaders(),
            expectDataType: http.HttpDataType.STRING,
            // 添加超时设置（10秒）

          },
          (err, data) => {
            if (err) {
              hilog.error(DOMAIN, 'NetworkService', 'GET request failed: %{public}s', JSON.stringify(err));
              reject(err instanceof Error ? err : new Error(String(err)));
              return;
            }
            try {
              // Always parse the response, even for non-OK status codes
              const responseData = JSON.parse(data.result as string) as T;
              resolve(responseData);
            } catch (parseError) {
              hilog.error(DOMAIN, 'NetworkService', 'JSON parse failed: %{public}s', JSON.stringify(parseError));
              reject(parseError instanceof Error ? parseError : new Error(String(parseError)));
            }
          }
        );
      });
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkService', 'GET request failed: %{public}s', JSON.stringify(error));
      throw error instanceof Error ? error : new Error(String(error));
    } finally {
      // 释放HTTP请求资源
      if (httpRequest) {
        httpRequest.destroy();
      }
    }
  }

  /**
   * 发送POST请求
   * @param path API路径
   * @param data 请求数据
   * @returns Promise<T> 响应数据
   */
  static async post<T>(path: string, data?: Object): Promise<T> {
    console.log('开始发送POST请求，路径:', path);
    console.log('请求数据:', JSON.stringify(data));
    
    const url = NetworkService.buildUrl(path);
    console.log('构建的完整URL:', url);
    
    let httpRequest: http.HttpRequest = http.createHttp();
    try {
      const headers = NetworkService.buildHeaders();
      console.log('请求头:', JSON.stringify(headers));
      
      // 使用Promise包装HTTP请求
      return await new Promise<T>((resolve, reject) => {
        console.log('开始执行HTTP请求');
        httpRequest.request(
          url,
          {
            method: http.RequestMethod.POST,
            header: headers,
            extraData: JSON.stringify(data),
            expectDataType: http.HttpDataType.STRING,
            // 添加超时设置（10秒）
          },
          (err, response) => {
            if (err) {
              console.error('POST请求失败:', err instanceof Error ? err.message : JSON.stringify(err));
              hilog.error(DOMAIN, 'NetworkService', 'POST request failed: %{public}s', JSON.stringify(err));
              reject(err instanceof Error ? err : new Error(String(err)));
              return;
            }
            
            console.log('HTTP请求执行完成，状态码:', response.responseCode);
            console.log('响应结果:', response.result);
            
            try {
              // Always parse the response, even for non-OK status codes
              const responseData = JSON.parse(response.result as string) as T;
              console.log('解析后的响应数据:', JSON.stringify(responseData));
              resolve(responseData);
            } catch (parseError) {
              console.error('JSON解析失败:', parseError instanceof Error ? parseError.message : JSON.stringify(parseError));
              hilog.error(DOMAIN, 'NetworkService', 'JSON parse failed: %{public}s', JSON.stringify(parseError));
              reject(parseError instanceof Error ? parseError : new Error(String(parseError)));
            }
          }
        );
      });
    } catch (error) {
      console.error('POST请求失败:', error instanceof Error ? error.message : JSON.stringify(error));
      hilog.error(DOMAIN, 'NetworkService', 'POST request failed: %{public}s', JSON.stringify(error));
      throw error instanceof Error ? error : new Error(String(error));
    } finally {
      // 释放HTTP请求资源
      if (httpRequest) {
        console.log('释放HTTP请求资源');
        httpRequest.destroy();
      }
    }
  }

  /**
   * 构建完整的URL
   * @param path API路径
   * @param params 请求参数，可以是对象或单个字符串
   * @returns string 完整URL
   */
  private static buildUrl(path: string, params?: ParamsObject | string): string {
    let url = `${NetworkService.BASE_URL}${path.startsWith('/') ? '' : '/'}${path}`;
    
    if (params) {
      if (typeof params === 'string') {
        // 如果params是字符串，直接添加到URL
        url += `?tag=${encodeURIComponent(params)}`;
      } else {
        // 如果params是对象，构建查询字符串
        const queryParams: string[] = [];
        // 使用明确类型的参数
        const entries = Object.entries(params);
        for (let i = 0; i < entries.length; i++) {
          const entry = entries[i];
          const key = entry[0];
          const value = entry[1];
          queryParams.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
        }
        if (queryParams.length > 0) {
          url += `?${queryParams.join('&')}`;
        }
      }
    }
    
    return url;
  }
}
