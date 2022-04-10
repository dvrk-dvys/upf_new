import nn

class DeepQNetwork():
    """
    A model that uses a Deep Q-value Network (DQN) to approximate Q(s,a) as part
    of reinforcement learning.
    """
    def __init__(self, state_dim, action_dim):
        self.num_actions = action_dim
        self.state_size = state_dim

        # Remember to set self.learning_rate, self.numTrainingGames,
        # self.parameters, and self.batch_size!
        "*** YOUR CODE HERE ***"
        self.batch_size = 100
        self.hiddenLayerSize = 150
        self.numTrainingGames = 5000
        self.learningRate = -0.8
        self.w1 = nn.Parameter(self.state_size, 100)
        self.b1 = nn.Parameter(1, 100)
        self.w2 = nn.Parameter(100, 300)
        self.b2 = nn.Parameter(1, 300)
        self.w3 = nn.Parameter(300, self.num_actions)
        self.b3 = nn.Parameter(1, self.num_actions)
        self.set_weights([self.w1, self.b1, self.w2, self.b2, self.w3, self.b3])

    def set_weights(self, layers):
        self.parameters = []
        for i in range(len(layers)):
            self.parameters.append(layers[i])

    def get_loss(self, states, Q_target):
        """
        Returns the Squared Loss between Q values currently predicted 
        by the network, and Q_target.
        Inputs:
            states: a (batch_size x state_dim) numpy array
            Q_target: a (batch_size x num_actions) numpy array, or None
        Output:
            loss node between Q predictions and Q_target
        """
        "*** YOUR CODE HERE ***"
        loss = nn.SquareLoss(self.run(states), Q_target)
        return loss

    def run(self, states):
        """
        Runs the DQN for a batch of states.
        The DQN takes the state and returns the Q-values for all possible actions
        that can be taken. That is, if there are two actions, the network takes
        as input the state s and computes the vector [Q(s, a_1), Q(s, a_2)]
        Inputs:
            states: a (batch_size x state_dim) numpy array
            Q_target: a (batch_size x num_actions) numpy array, or None
        Output:
            result: (batch_size x num_actions) numpy array of Q-value
                scores, for each of the actions
        """
        "*** YOUR CODE HERE ***"
        layer1 = nn.ReLU(nn.AddBias(nn.Linear(states, self.w1), self.b1))
        layer2 = nn.ReLU(nn.AddBias(nn.Linear(layer1, self.w2), self.b2))
        return nn.AddBias(nn.Linear(layer2, self.w3), self.b3)

    def gradient_update(self, states, Q_target):
        """
        Update your parameters by one gradient step with the .update(...) function.
        Inputs:
            states: a (batch_size x state_dim) numpy array
            Q_target: a (batch_size x num_actions) numpy array, or None
        Output:
            None
        """
        "*** YOUR CODE HERE ***"
        x, y = states, Q_target
        loss = self.get_loss(x, y)
        grad_wrt_w1, grad_wrt_b1, grad_wrt_w2, grad_wrt_b2, grad_wrt_w3, grad_wrt_b3 = nn.gradients(loss, self.parameters)
        self.parameters[0].update(grad_wrt_w1, self.learningRate)
        self.parameters[1].update(grad_wrt_b1, self.learningRate)
        self.parameters[2].update(grad_wrt_w2, self.learningRate)
        self.parameters[3].update(grad_wrt_b2, self.learningRate)
        self.parameters[4].update(grad_wrt_w3, self.learningRate)
        self.parameters[5].update(grad_wrt_b3, self.learningRate)