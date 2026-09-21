import { sum, subtract, multiply, divide } from './math';

describe('Math functions', () => {
    test('1. sum should add two numbers correctly', () => {
        expect(sum(2, 3)).toBe(5);
    });

    test('2. subtract should subtract two numbers correctly', () => {
        expect(subtract(5, 3)).toBe(2);
    });

    test('3. multiply should multiply two numbers correctly', () => {
        expect(multiply(4, 3)).toBe(12);
    });

    test('4. divide should divide two numbers correctly', () => {
        expect(divide(10, 2)).toBe(5);
    });

    test('5. divide should throw an error when dividing by zero', () => {
        expect(() => divide(10, 0)).toThrow("Cannot divide by zero");
    });
});
