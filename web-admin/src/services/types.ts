// =========================
// Base Entity Types
// =========================

export interface Category {
  id: number;
  name: string;
}

export interface Proxy {
  id: number;
  hostAddress: string;
  description: string;
  builtIn: boolean;
}

export interface HostRule {
  id: number;
  hostTemplate: string;
  strict: boolean;
  category: Category;
}

export interface ProxyRules {
  id: number;
  proxy: Proxy;
  enabled: boolean;
  name: string;
  hostRules: HostRule[];
}

export interface Pac {
  id: number;
  name: string;
  description: string;
  proxyRules: ProxyRules[];
  serve: boolean;
  servePath: string;
  saveToFS: boolean;
  saveToFSPath: string;
}

// =========================
// Category API Responses
// =========================

export interface CategoryAllResponse {
  categories: Category[];
}

export interface CategoryFilterResponse {
  categories: Category[];
}

export type CategoryGetByIdResponse = Category;
export type CategoryCreateResponse = Category;
export type CategoryUpdateResponse = Category;
export type CategoryDeleteResponse = Category;

// =========================
// Proxy API Responses
// =========================

export interface ProxyAllResponse {
  proxies: Proxy[];
}

export interface ProxyFilterResponse {
  proxies: Proxy[];
}

export type ProxyGetByIdResponse = Proxy;
export type ProxyCreateResponse = Proxy;
export type ProxyUpdateResponse = Proxy;
export type ProxyDeleteResponse = Proxy;

// =========================
// Host Rule API Responses
// =========================

export interface HostRuleAllResponse {
  hostRules: HostRule[];
}

export type HostRuleGetByIdResponse = HostRule;
export type HostRuleCreateResponse = HostRule;
export type HostRuleUpdateResponse = HostRule;
export type HostRuleDeleteResponse = HostRule;

// =========================
// Proxy Rules API Responses
// =========================

export interface ProxyRulesAllResponse {
  proxyRules: ProxyRules[];
}

export type ProxyRulesGetByIdResponse = ProxyRules;
export type ProxyRulesCreateResponse = ProxyRules;
export type ProxyRulesUpdateResponse = ProxyRules;
export type ProxyRulesDeleteResponse = ProxyRules;

export interface ProxyRulesHostRulesResponse {
  hostRules: HostRule[];
}

// These two endpoints return updated hostRules after mutation
export type ProxyRulesAddHostRuleResponse = ProxyRulesHostRulesResponse;
export type ProxyRulesDeleteHostRuleResponse = ProxyRulesHostRulesResponse;

// =========================
// PAC API Responses
// =========================

export interface PacAllResponse {
  pacs: Pac[];
}

export type PacGetByIdResponse = Pac;
export type PacCreateResponse = Pac;
export type PacUpdateResponse = Pac;
// Delete response is empty JSON (no content)
export type PacDeleteResponse = Record<string, never>;

// Linked proxy rules for PAC
export interface PacProxyRulesResponse {
  proxyRules: ProxyRules[];
}

// These return updated proxyRules after mutation
export type PacAddProxyRulesResponse = PacProxyRulesResponse;
export type PacDeleteProxyRulesResponse = PacProxyRulesResponse;
