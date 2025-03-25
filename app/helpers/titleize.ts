import { helper } from '@ember/component/helper';

interface TitleizeSignature {
  Args: {
    Positional: [string];
    Named: Record<string, never>;
  };
  Return: string;
}

export function titleize(word: string): string {
  if (typeof word !== 'string') {
    throw new Error('titleize helper requires a string argument');
  }

  return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
}

export default helper<TitleizeSignature>(function ([word]: [string]) {
  return titleize(word);
});
