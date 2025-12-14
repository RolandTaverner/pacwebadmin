import React from 'react';

import type { Proxy } from "../../services/types";

import EllipsisTextWithHint from './EllipsisTextWithHint';

const ProxyCell: React.FC<{
  proxy?: Proxy;
  maxWidth: string | number | undefined
}> = ({ proxy, maxWidth }) => {
  return (
    <EllipsisTextWithHint longText={displayProxyString(proxy)} maxWidth={maxWidth} />
  );
};

function displayProxyString(p?: Proxy): string {
  if (!p) {
    return 'undefined';
  }
  const proxyAddr = p.type + (p.address.length != 0 ? ' ' + p.address : '');

  return (p.description.length != 0 ? p.description + ' (' + proxyAddr + ')' : proxyAddr);
}

export { displayProxyString };

export default ProxyCell;
