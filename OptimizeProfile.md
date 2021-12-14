# Optimize Profile

https://devblogs.microsoft.com/powershell/optimizing-your-profile/

```powershell
Install-Module PSProfiler
Import-Module PSProfiler
Measure-Script -Path $profile -Top 5
```

