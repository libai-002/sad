/**
 * 对象字面量类型声明示例
 * 展示如何正确解决"Object literal must correspond to some explicitly declared class or interface"错误
 */

// 方法1：使用接口(interface)定义对象结构
interface Person {
  id: number;
  name: string;
  age?: number;
  email?: string;
}

// 方法2：使用类型别名(type)定义对象结构
type Product = {
  id: number;
  name: string;
  price: number;
  description?: string;
};

// 方法3：使用泛型接口定义通用响应结构
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
}

// 正确的对象字面量使用方式

// 方式1：显式类型注解
const person1: Person = {
  id: 1,
  name: "张三",
  age: 25,
  email: "zhangsan@example.com"
};

// 方式2：类型断言
const person2 = {
  id: 2,
  name: "李四",
  age: 30
} as Person;

// 方式3：函数参数类型声明
function createPerson(person: Person): Person {
  return person;
}

// 调用函数时传入对象字面量
const person3 = createPerson({
  id: 3,
  name: "王五"
});

// 方式4：返回值类型声明
function getDefaultProduct(): Product {
  return {
    id: 0,
    name: "默认产品",
    price: 0
  };
}

// 方式5：使用泛型
const response: ApiResponse<Person> = {
  success: true,
  data: {
    id: 4,
    name: "赵六"
  },
  message: "获取成功"
};

// 常见错误示例及修复方法

// 错误示例1：直接使用对象字面量赋值给无类型变量
// let user = { id: 1, name: "用户" }; // 可能会报错

// 修复方法：添加类型注解
let user: Person = { id: 1, name: "用户" };

// 错误示例2：函数参数没有类型声明
// function updateUser(user) { // 可能会报错
//   return user;
// }

// 修复方法：添加参数类型声明
function updateUser(user: Person) {
  return user;
}

// 错误示例3：返回对象字面量时没有类型声明
// function createUser() { // 可能会报错
//   return { id: 1, name: "用户" };
// }

// 修复方法：添加返回值类型声明
function createUser(): Person {
  return { id: 1, name: "用户" };
}

// 实际项目中的应用示例
class UserService {
  // 正确的方法：使用接口定义参数和返回值类型
  static async getUserProfile(): Promise<Person> {
    // 模拟API调用
    return {
      id: 1,
      name: "当前用户",
      age: 28,
      email: "user@example.com"
    };
  }

  // 正确的方法：使用类型断言处理空对象
  static async getAccountSecurity(): Promise<{ twoFactorEnabled?: boolean }> {
    // 后端没有提供安全信息接口，返回默认空对象
    return {} as { twoFactorEnabled?: boolean };
  }
}

// 导出类型和示例供其他文件使用
export { Person, Product, ApiResponse, UserService };
export type { Person as UserPerson }; // 类型重导出