#!/usr/bin/env node

import * as p from '@clack/prompts';
import { setTimeout } from  'node:timers/promises';
import color from 'picolors';

class Question {
    constructor(question, answersArray, correctAnswerIndex){
        this.question = question;
        this.answersArray= answersArray;
        this.correctAnswerIndex = correctAnswerIndex;
    }
}

async function main() {
    p.intro(`${color.bgMagenta(color.black('Welcome amigo idiota'))}`)
    const question1 = new Question
    p.intro(`${color.bgMagenta(color.black('Adios idiota'))}`)

}