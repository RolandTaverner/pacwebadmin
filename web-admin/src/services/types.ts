// ============================
// Enums
// ============================

export type ProxyType =
  | "DIRECT"
  | "PROXY"
  | "SOCKS"
  | "SOCKS4"
  | "SOCKS5"
  | "HTTP"
  | "HTTPS";

export type ConditionType =
  | "host_domain_only"
  | "host_domain_subdomain"
  | "host_subdomain_only"
  | "url_shexp_match"
  | "url_regexp_match";


// ============================
// Base entities
// ============================

export interface Category {
  id: number;
  name: string;
}

export interface Proxy {
  id: number;
  type: ProxyType;
  address: string;
  description: string;
}

export interface Condition {
  id: number;
  type: ConditionType;
  expression: string;
  category: Category;
}

export interface ProxyRule {
  id: number;
  proxy: Proxy;
  enabled: boolean;
  name: string;
  conditions: Condition[];
}

export interface ProxyRuleWithPriority {
  proxyRule: ProxyRule;
  priority: number;
}

export interface PAC {
  id: number;
  name: string;
  description: string;

  proxyRules: ProxyRuleWithPriority[];

  serve: boolean;
  servePath: string;

  saveToFS: boolean;
  saveToFSPath: string;

  fallbackProxy: Proxy;
}


// ============================
// Error response
// ============================

export interface ErrorResponse {
  statusMessage: string;
}


// ============================
// Category API
// ============================

export interface CategoryFilterRequest {
  name: string;
}

export interface CategoryCreateRequest {
  name: string;
}

export interface CategoryUpdateRequest {
  name: string;
}

export interface CategoriesResponse {
  categories: Category[];
}

export type CategoryGetByIdResponse = Category;
export type CategoryCreateResponse = Category;
export type CategoryUpdateResponse = Category;


// ============================
// Proxy API
// ============================

export interface ProxiesResponse {
  proxies: Proxy[];
}

export interface ProxyFilterRequest {
  type?: string;
  address?: string;
}

export interface ProxyCreateRequest {
  type: ProxyType;
  address: string;        // empty if type == DIRECT
  description?: string;
}

export interface ProxyUpdateRequest {
  type?: ProxyType;
  address?: string;
  description?: string;
}

export type ProxyGetByIdResponse = Proxy;
export type ProxyCreateResponse = Proxy;
export type ProxyUpdateResponse = Proxy;


// ============================
// Condition API
// ============================

export interface ConditionsResponse {
  conditions: Condition[];
}

export interface ConditionCreateRequest {
  type: ConditionType;
  expression: string;
  categoryId: number;
}

export interface ConditionUpdateRequest {
  type?: ConditionType;
  expression?: string;
  categoryId?: number;
}

export type ConditionGetByIdResponse = Condition;
export type ConditionCreateResponse = Condition;
export type ConditionUpdateResponse = Condition;


// ============================
// Proxy Rule API
// ============================

export interface ProxyRulesResponse {
  proxyRules: ProxyRule[];
}

export interface ProxyRuleConditionsResponse {
  conditions: Condition[];
}

export interface ProxyRuleCreateRequest {
  proxyId: number;
  enabled: boolean;
  name: string;
  conditionIds: number[];
}


export interface ProxyRuleUpdateRequest {
  proxyId?: number;
  enabled?: boolean;
  name?: string;
  conditionIds?: number[];
}

export type ProxyRuleGetByIdResponse = ProxyRule;
export type ProxyRuleCreateResponse = ProxyRule;
export type ProxyRuleUpdateResponse = ProxyRule;

export interface ProxyRuleAddConditionRequest {
  id: number,
  conditionId: number,
}

export type ProxyRuleAddConditionResponse = ProxyRuleConditionsResponse;

export interface ProxyRuleRemoveConditionRequest {
  id: number,
  conditionId: number,
}

export type ProxyRuleRemoveConditionResponse = ProxyRuleConditionsResponse;

// ============================
// PAC API
// ============================

export interface PACsResponse {
  pacs: PAC[];
}

export interface ProxyRuleWithPriority {
  proxyRuleId: number;
  priority: number;
}

export interface PACCreateRequest {
  name: string;
  description: string;
  proxyRules: ProxyRuleWithPriority[];
  fallbackProxyId: number;
  serve: boolean;
  servePath: string;
  saveToFS: boolean;
  saveToFSPath: string;
}

export interface PACUpdateRequest {
  name?: string;
  description?: string;
  proxyRules?: ProxyRuleWithPriority[];
  fallbackProxyId?: number;
  serve?: boolean;
  servePath?: string;
  saveToFS?: boolean;
  saveToFSPath?: string;
}

export type PACGetByIdResponse = PAC;
export type PACCreateResponse = PAC;
export type PACUpdateResponse = PAC;

export interface PACProxyRulesResponse {
  proxyRules: ProxyRuleWithPriority[];
}

export interface PACProxyRuleAddRequest {
  id: number;
  proxyRuleId: number;
  priority: number;  
}

export type PACProxyRuleAddResponse = PACProxyRulesResponse;

export interface PACProxyRuleRemoveRequest {
  id: number;
  proxyRuleId: number;
}

export type PACProxyRuleRemoveResponse = PACProxyRulesResponse;
