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

export interface ProxyItem {
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
  proxy: ProxyItem;
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

  fallbackProxy: ProxyItem;
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

export interface CategoriesResponse {
  categories: Category[];
}

export interface CategoryCreateRequest {
  name: string;
}

export interface CategoryUpdateRequest {
  name: string;
}


// ============================
// Proxy API
// ============================

export interface ProxiesResponse {
  proxies: ProxyItem[];
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


// ============================
// PAC API
// ============================

export interface PACListResponse {
  pacs: PAC[];
}

export interface PACRulesResponse {
  proxyRules: ProxyRuleWithPriority[];
}

export interface PACProxyRuleLinkRequest {
  proxyRuleId: number;
  priority: number;
}

export interface PACRuleRef {
  proxyRuleId: number;
  priority: number;
}

export interface PacCreateRequest {
  name: string;
  description: string;
  proxyRules: PACRuleRef[];
  fallbackProxyId: number;
  serve: boolean;
  servePath: string;
  saveToFS: boolean;
  saveToFSPath: string;
}

export interface PacUpdateRequest {
  name?: string;
  description?: string;
  proxyRules?: PACRuleRef[];
  fallbackProxyId?: number;
  serve?: boolean;
  servePath?: string;
  saveToFS?: boolean;
  saveToFSPath?: string;
}
