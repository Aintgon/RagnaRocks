import numpy as np

try:
    # let's import `tqdm` if exists. Otherwise, it's fine too.
    # install from pip or something if you want it.
    from tqdm import tqdm
except ModuleNotFoundError:
    tqdm = lambda x: x  # noqa: E731
# other imports are allowed as well..


#######################################
# Here is whatever is needed to set up the problem
#######################################

def random_sequence(b, N):
    for n in range(N):
        yield n, np.random.randint(1, b + 1)  # b inclusive

def hit(b_predict, b_true, deviation):
    '''
    Arguments:
        b_predict: int, the predicted value of the upper bound b.
        b_true: int, the true value of the upper bound b.
        deviation: int, the allowed deviation
    '''
    is_hit = b_true - deviation <= b_predict <= b_true + deviation
    return 1 if is_hit else 0


def run_problem_instances(f, T, N_min, N_max, b_min, b_max):
    '''
    f: Our function that takes in `sequence, N, m`
        sequence: a generator function that yields (n, value) until `N`
        N: The total amount of values we see if we never predict early.
        m: The allowed deviation
    T: int, the number of trials.
    N_min, N_max: lower and upper bounds for `N`
    b_min, bmax: lower and upper bounds for `b`.
    '''
    print(f,'Running {T} trials.')
    tot_penalty = 0
    for t in tqdm(range(T)):
        N = np.random.randint(N_min, N_max)
        b_true = np.random.randint(b_min, b_max)

        # we let `m` (the deviation) be anywhere between 1% and 25% of `N`. :)
        deviation = int(N * np.random.uniform(0.01, 0.25))
        seq = random_sequence(b_true, N)
        n, b_predict = f(seq, N, deviation)
        tot_penalty += n / N + (0 if hit(b_predict, b_true, deviation) else 1)
#        print(N,n,b_predict,tot_penalty,hit(b_predict, b_true, deviation))
    mean_penalty = tot_penalty / T
    score = 1 - mean_penalty
#    print(f,'Mean score {score:.3f} on {T} trials. The higher the better :)')
    return score,b_predict,b_true,n,N


#######################################
# Define your function here. They should have the same arguments as
# `my_silly_f`. Create new ones or just override this one.
#######################################
def my_silly_f(sequence, N, m):
    '''
    Arguments:
        sequence: a generator that yields (0, num0), ..., (N-1, numN-1)
        N: the upper limit of the sequence
        m: the allowed deviation of `b_predict`.
    '''
    # naive implementation: We just go through 50% of the
    # dataset and return the maximum value, hoping that is a good estimate.
    # Notice that we need to return `(n, b_predict)`, not `b_predict` alone!

    b_predict = -np.inf
    silly_counter = 0
    for n, value in sequence:
        b_predict = max(b_predict, value)
        n = int(b_predict/(1-b_predict+ b_true));
        silly_counter += 1
        if silly_counter * 50 >= N:
            b_predict = int(b_predict * 1.50)
            return n, b_predict


def another_silly_that_goes_through_all_data(sequence, N, m):
    # since we go through all the data we are certain that we have the correct
    # value: `b_predict == b_true`, but `n/N == N/N == 1`, so the total score
    # will be 0 in this case.
    b_predict = -np.inf
    for n, value in sequence:
        b_predict = max(b_predict, value)
    return n, b_predict


#######################################
# Finally, let's call the script
#######################################


if __name__ == '__main__':
    # Notice that we also might use other values for the parameters `N_min,
    # N_max, b_min, b_max`.  up to `N_max = 100_000_000` and
    # `b_max = 100_000_000`. We just set the limit at 100_000 for now to make
    # the code run fast.
  
    T = 100
    N_min, N_max = (100, 10000000)
    b_min, b_max = (100, 10000000)
#    score,b_predict,b_true,n,N = run_problem_instances(another_silly_that_goes_through_all_data, T,
#                          N_min, N_max, b_min, b_max)
    score,b_predict,b_true,n,N =  run_problem_instances(my_silly_f, T,
                           N_min, N_max, b_min, b_max)
    print('score=',score,'b_predict=',b_predict,'b_true=',b_true,'n=',n,'N=',N)