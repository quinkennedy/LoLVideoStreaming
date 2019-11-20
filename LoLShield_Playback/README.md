This will play back the byte array created by the 
File recording mode (__F__) in LoLProcessing_VideoStream.

Here is how I process the out.json into a usable Arduino byte matrix:

1. open the file in your favorite editing program
   - VIM
2. replace `]` with `}` followed by a newline
   - `:%s/\]/\}\r/g`
3. replace `[` with `{`
   - `:%s/\[/\{/g`
4. copy to clipboard
   - `:x! temp.txt`
   - `cat temp.txt | pbcopy`
5. replace _BitMap_ contents (in the Arduino sketch) with the clipboard
6. add a final `,{128}` to the end of the _BitMap_ to signal the end of the array
7. add a trailing `;` to the _BitMap_ array definition
8. tweak _blinkdelay_ as you see fit

Upload to your Arduino and enjoy the looping video!
