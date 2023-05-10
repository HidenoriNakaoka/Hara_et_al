'''
https://docs.scipy.org/doc//scipy-1.2.3/reference/generated/scipy.stats.anderson_ksamp.html
https://docs.scipy.org/doc//scipy-1.2.3/reference/generated/scipy.stats.ks_2samp.html#scipy.stats.ks_2samp

 scipy.stats.anderson_ksamp(samples, midrank=True)[source]¶

    The Anderson-Darling test for k-samples.

    The k-sample Anderson-Darling test is a modification of the one-sample Anderson-Darling test. It tests the null hypothesis that k-samples are drawn from the same population without having to specify the distribution function of that population. The critical values depend on the number of samples.

    Parameters

        samplessequence of 1-D array_like

            Array of sample data in arrays.
        midrankbool, optional

            Type of Anderson-Darling test which is computed. Default (True) is the midrank test applicable to continuous and discrete populations. If False, the right side empirical distribution is used.

    Returns

        statistic: float

            Normalized k-sample Anderson-Darling test statistic.
        critical_values: array

            The critical values for significance levels 25%, 10%, 5%, 2.5%, 1%.
        significance_level: float

            An approximate significance level at which the null hypothesis for the provided samples can be rejected. The value is floored / capped at 1% / 25%.

    Raises

        ValueError

            If less than 2 samples are provided, a sample is empty, or no distinct observations are in the samples.


scipy.stats.ks_2samp(data1, data2)[source]¶

    Compute the Kolmogorov-Smirnov statistic on 2 samples.

    This is a two-sided test for the null hypothesis that 2 independent samples are drawn from the same continuous distribution.

    Parameters

        data1, data2sequence of 1-D ndarrays

            two arrays of sample observations assumed to be drawn from a continuous distribution, sample sizes can be different

    Returns

        statisticfloat

            KS statistic
        pvaluefloat

            two-tailed p-value


'''
import numpy as np
from scipy import stats
import pandas as pd
import math

neutral_comet = "/Users/nakaokahidenori/Documents/Publications/2023_Hara_CST/analysis/NeutralComet.xls"

df = pd.read_excel(neutral_comet)

'''print the column names
columns = df.columns
print(columns)
'''

KDctrl_H2O2 = list(filter(lambda x: not math.isnan(x), df["KDctrl_H2O2"]))
shSTN1_H2O2 = list(filter(lambda x: not math.isnan(x), df["shSTN1_H2O2"]))

'''
print(len(KDctrl_H2O2))
print(len(shSTN1_H2O2))
'''

res = stats.anderson_ksamp([KDctrl_H2O2, shSTN1_H2O2], midrank=True)
print(res)  # anderson k sample test results

res = stats.ks_2samp(KDctrl_H2O2, shSTN1_H2O2)
print(res)  # KS 2 sample test results

'''
Anderson_ksampResult(
statistic=4.799780851576188, 
critical_values=array([0.325, 1.226, 1.961, 2.718, 3.752, 4.592, 6.546]), 
significance_level=0.004095808997779653
)

KstestResult(
statistic=0.13804287817445712, 
pvalue=0.030955635147087403
)
'''