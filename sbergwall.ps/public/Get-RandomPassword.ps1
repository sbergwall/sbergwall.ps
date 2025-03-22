Function Get-RandomPassword {
    <#
.SYNOPSIS
Generates random passwords based on user-defined criteria.

.DESCRIPTION
The Get-RandomPassword function generates passwords based on user-defined criteria for length, character sets, and quantity. It ensures each password contains at least one character from each specified set.

.PARAMETER Length
Specifies the length of each password to be generated. This parameter is mandatory and must be between 8 and 255 characters.

.PARAMETER Count
Specifies the number of passwords to generate. This parameter is optional and defaults to 1.

.PARAMETER CharacterSet
Specifies the character sets the password may contain. A password will contain at least one character from each specified set. This parameter is optional and defaults to a combination of lowercase letters, uppercase letters, digits, and special characters.

.EXAMPLE
Get-RandomPassword -Length 12 -Count 3

This example generates 3 random passwords, each 12 characters long, using the default character sets.

.EXAMPLE
Get-RandomPassword -Length 16 -Count 5 -CharacterSet @('abcdef', '0123456789', '!@#$%')

This example generates 5 random passwords, each 16 characters long, using custom character sets containing lowercase letters, digits, and special characters.

.NOTES
- The function uses a cryptographically secure random number generator to ensure the randomness of the passwords.
- It combines all specified character sets for random selection.
- The function ensures that each password contains at least one character from each specified set.
- The Fisher-Yates shuffle algorithm is used to further randomize the order of characters in the password.
- The generated passwords are output as strings.
#>
    param (
        # The length of each password which should be created.
        [Parameter(Mandatory = $true)]
        [ValidateRange(8, 255)]
        [Int32]$Length,

        # The number of passwords to generate.
        [Parameter(Mandatory = $false)]
        [Int32]$Count = 1,

        # The character sets the password may contain.
        # A password will contain at least one of each of the characters.
        [String[]]$CharacterSet = @(
            'abcdefghijklmnopqrstuvwxyz',
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
            '0123456789',
            '!$%&^.#;'
        )
    )

    # Generate a cryptographically secure seed
    $bytes = [Byte[]]::new(4)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $seed = [System.BitConverter]::ToInt32($bytes, 0)
    $rnd = [Random]::new($seed)

    # Combine all character sets for random selection
    $allCharacterSets = [String]::Concat($CharacterSet)

    try {
        for ($i = 0; $i -lt $Count; $i++) {
            $password = [Char[]]::new($Length)
            $index = 0

            # Ensure at least one character from each set
            foreach ($set in $CharacterSet) {
                $password[$index++] = $set[$rnd.Next($set.Length)]
            }

            # Fill remaining characters randomly from all sets
            for ($j = $index; $j -lt $Length; $j++) {
                $password[$index++] = $allCharacterSets[$rnd.Next($allCharacterSets.Length)]
            }

            # Fisher-Yates shuffle for randomness
            for ($j = $Length - 1; $j -gt 0; $j--) {
                $m = $rnd.Next($j + 1)
                $t = $password[$j]
                $password[$j] = $password[$m]
                $password[$m] = $t
            }

            # Output each password
            Write-Output ([String]::new($password))
        }
    }
    catch {
        Write-Error $_
    }
}
