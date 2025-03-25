import { helper } from '@ember/component/helper';
import { titleize } from 'dealfront/helpers/titleize';

interface PluralizeSignature {
  Args: {
    Positional: [number, string];
    Named: Record<string, never>;
  };
  Return: string;
}

export default helper<PluralizeSignature>(function pluralize([number, word]: [
  number,
  string,
]): string {
  if (typeof number !== 'number' || typeof word !== 'string') {
    throw new Error('pluralize helper requires a number and string argument');
  }

  const isSingle = number.toString().endsWith('1');

  return titleize(isSingle ? word : word + 'es');
});
